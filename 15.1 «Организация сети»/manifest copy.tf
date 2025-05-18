terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.94.0" # Обновленная версия провайдера
    }
  }
}

provider "yandex" {
  token     = "y0__xCD5fl1GMHdEyCIismRE5jhEYCORdmkx831UtAK_jwSfm2P"
  cloud_id  = "b1gri9i35rd1ghpm0kjd"
  folder_id = "b1gfs13q5qak7jlkueuf"
  zone      = "ru-central1-a"
}

# 1. Создание VPC сети
resource "yandex_vpc_network" "network" {
  name = "main-network"
}

# 2. Создание публичной подсети
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.10.1.0/24"]
  zone           = "ru-central1-a"
  route_table_id = yandex_vpc_route_table.public_rt.id
}

# 3. Создание приватной подсети
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.10.2.0/24"]
  zone           = "ru-central1-a"
  route_table_id = yandex_vpc_route_table.private_rt.id
}

# 4. Internet Gateway
resource "yandex_vpc_gateway" "igw" {
  name = "internet-gateway"
  shared_egress_gateway {}
}

# 5. NAT Instance вместо NAT Gateway
resource "yandex_compute_instance" "nat_instance" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1" # Ubuntu 22.04
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      runcmd:
        - sysctl -w net.ipv4.ip_forward=1
        - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    EOF
  }
}

# 6. Таблица маршрутизации для публичной подсети
resource "yandex_vpc_route_table" "public_rt" {
  network_id = yandex_vpc_network.network.id
  name       = "public-route-table"

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.igw.id
  }
}

# 7. Таблица маршрутизации для приватной подсети
resource "yandex_vpc_route_table" "private_rt" {
  network_id = yandex_vpc_network.network.id
  name       = "private-route-table"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat_instance.network_interface.0.ip_address
  }
}

# 8. Security Group
resource "yandex_vpc_security_group" "main_sg" {
  name        = "main-sg"
  network_id  = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 9. Виртуалка в публичной подсети (бастион)
resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.main_sg.id]
    nat                = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# 10. Виртуалка в приватной подсети
resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    security_group_ids = [yandex_vpc_security_group.main_sg.id]
    nat                = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}