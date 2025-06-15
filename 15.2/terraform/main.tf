# main.tf
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.89.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# 1. Создаем VPC и подсети
resource "yandex_vpc_network" "network" {
  name = "kuliaev-april-o2-network"
}

resource "yandex_vpc_subnet" "public_subnet" {
  name           = "public-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# 2. Создаем сервисный аккаунт для бакета
resource "yandex_iam_service_account" "sa" {
  name        = "sa-kuliaev-april-o2"
  description = "Service account for bucket and instance group"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "Static access key for bucket"
}

# 3. Создаем бакет и загружаем картинку
resource "yandex_storage_bucket" "bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-key.secret_key
  bucket     = "kuliaev-april-o2"
  
  anonymous_access_flags {
    read = true
    list = false
  }
}

resource "yandex_storage_object" "image" {
  bucket      = yandex_storage_bucket.bucket.bucket
  access_key  = yandex_iam_service_account_static_access_key.sa-key.access_key
  secret_key  = yandex_iam_service_account_static_access_key.sa-key.secret_key
  key         = "devops.jpg"
  source      = "./devops.jpg"
  acl         = "public-read"
}

# 4. Создаем группу ВМ с LAMP
data "yandex_compute_image" "lamp" {
  family = "lamp"
}

resource "yandex_compute_instance_group" "lamp-group" {
  name               = "lamp-group-kuliaev"
  folder_id          = var.yc_folder_id
  service_account_id = yandex_iam_service_account.sa.id
  deletion_protection = false

  instance_template {
    platform_id = "standard-v3"
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.lamp.id
        size     = 10
      }
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.public_subnet.id]
      nat       = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = <<-EOF
        #cloud-config
        runcmd:
          - cd /var/www/html
          - echo '<html><h1>Kuliaev April O2</h1><img src="http://${yandex_storage_bucket.bucket.bucket_domain_name}/${yandex_storage_object.image.key}"/></html>' | sudo tee index.html
          - sudo systemctl restart apache2
      EOF
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.yc_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name        = "lamp-target-group"
    target_group_description = "Target group for LAMP instances"
  }

  health_check {
    interval = 2
    timeout  = 1
    tcp_options {
      port = 80
    }
  }
}

# 5. Создаем Network Load Balancer
resource "yandex_lb_network_load_balancer" "nlb" {
  name = "nlb-kuliaev-april-o2"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp-group.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

# 6. (Дополнительно) Создаем Application Load Balancer
resource "yandex_vpc_address" "alb-address" {
  name = "alb-address-kuliaev"
  external_ipv4_address {
    zone_id = var.yc_zone
  }
}

resource "yandex_alb_target_group" "lamp-target-group" {
  name           = "lamp-target-group-kuliaev"
  
  target {
    subnet_id   = yandex_vpc_subnet.public_subnet.id
    ip_address  = yandex_compute_instance_group.lamp-group.instances[0].network_interface[0].ip_address
  }
  
  target {
    subnet_id   = yandex_vpc_subnet.public_subnet.id
    ip_address  = yandex_compute_instance_group.lamp-group.instances[1].network_interface[0].ip_address
  }
  
  target {
    subnet_id   = yandex_vpc_subnet.public_subnet.id
    ip_address  = yandex_compute_instance_group.lamp-group.instances[2].network_interface[0].ip_address
  }
}

resource "yandex_alb_backend_group" "lamp-backend-group" {
  name = "lamp-backend-group-kuliaev"

  http_backend {
    name             = "lamp-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.lamp-target-group.id]
    healthcheck {
      timeout          = "1s"
      interval         = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "lamp-router" {
  name = "lamp-router-kuliaev"
}

resource "yandex_alb_virtual_host" "lamp-host" {
  name           = "lamp-host-kuliaev"
  http_router_id = yandex_alb_http_router.lamp-router.id
  route {
    name = "lamp-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.lamp-backend-group.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name               = "alb-kuliaev-april-o2"
  network_id         = yandex_vpc_network.network.id

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.public_subnet.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.alb-address.external_ipv4_address[0].address
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.lamp-router.id
      }
    }
  }

  depends_on = [
    yandex_alb_backend_group.lamp-backend-group,
    yandex_alb_target_group.lamp-target-group
  ]
}

# Outputs
output "bucket_url" {
  value = "http://${yandex_storage_bucket.bucket.bucket_domain_name}/${yandex_storage_object.image.key}"
}

output "nlb_public_ip" {
  value = one([
    for listener in yandex_lb_network_load_balancer.nlb.listener : 
    one(listener.external_address_spec[*].address)
  ])
}

output "alb_public_ip" {
  value = yandex_vpc_address.alb-address.external_ipv4_address[0].address
}

output "alb_target_group_id" {
  value = yandex_alb_target_group.lamp-target-group.id
}