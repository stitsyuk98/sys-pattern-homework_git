
###2

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "ubuntu"
}

variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
  description = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "platform id"
}

variable "vm_web_cores" {
  type        = string
  default     = "2"
  description = "cpu"
}

variable "vm_web_memory" {
  type        = string
  default     = "1"
  description = "memory"
}

variable "vm_web_core_fraction" {
  type        = string
  default     = "5"
  description = "core fraction"
}

variable "vm_web_nat" {
  type        = string
  default     = "true"
  description = "nat"
}

variable "vm_web_preemptible" {
  type        = string
  default     = "true"
  description = "preemptible"
}

variable "vm_web_serial_port_enable" {
  type        = string
  default     = "1"
  description = "serial port enable"
}



###3

variable "vm_db_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "ubuntu"
}

variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "netology-develop-platform-db"
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "platform id"
}

variable "vm_db_cores" {
  type        = string
  default     = "2"
  description = "cpu"
}

variable "vm_db_memory" {
  type        = string
  default     = "2"
  description = "memory"
}

variable "vm_db_core_fraction" {
  type        = string
  default     = "20"
  description = "core fraction"
}

variable "vm_db_nat" {
  type        = string
  default     = "true"
  description = "nat"
}

variable "vm_db_preemptible" {
  type        = string
  default     = "true"
  description = "preemptible"
}

variable "vm_db_serial_port_enable" {
  type        = string
  default     = "1"
  description = "serial port enable"
}

variable "vms_resources" {
  description = "all vms"
  type        = map(map(number))
  default     = {
    vm_web_resources = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
    vm_db_resources = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

variable "common_metadata" {
  description = "metadata for all vms"
  type        = map(string)
  default     = {
    serial-port-enable = "1"
    ssh-keys          = "ubuntu:ssh-rsa AAAAB3Nz/Dyv919+dKTfmW95rlp29A8L6EpW3JzvrjyqxU7gtlPnK7hwRc2Q6I2QUBzaLUaxlBreLwHu1Moz7zO5erVolKI7QR6OOa22BjKHkGD1zvHywac4lztwsP4Rx1CJsuhYTiAhvxjgW2R5FgStydiL/z2kokO++cJAtg7Ip/P1S/hwUv9tHOMg0GTSfqIV7SGpsabLreAMoVFY4uy2IwVGPWS/fUCE7WZUDPUEVeLY1Q/4c2GsCycv+2eorxR0OU43aOlLqDEZg63SX6vWH4Yu3OMR/+c1WA+dcQQIMbYdK96z11MPg9KhsKjiitHIvA5Lbc5xxYi9foAVRGnclgjBzD0KhkhVNn4wFmERYbJMsb/eoUMF3o6cFL3bd7L+NEx7Q2ms5PMfFAAu5sTU6miT8XKX3bc8JkW7HZb5r9m8HMSD0GAxuyYxUf/aLEWpPTLbKEE86bHru5/ubtEvBCLPOJ9KV0= stitsyuk@vm2"
  }
}
