###cloud vars
variable "token" {
  type        = string
  default     = "t1.9euelZrIkMkhHtM3n9euelZrHzj5yZjJGQkpvGlcbG.N7RIIUG3f_lTakIpZm6NDnBQN_E-tpAyDHEGP_BTHZ4rgEl3IAChTdUZhjv9R9ZTTuCHoQ-r_E8_2ePljoRGBg"
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}


###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAtlPnK7hwRc2Q6I2QUBzaLUaxlBreLwHu1Moz7zO5erVolKI7QR6OOa22BjKHkGD1zvHywac4lztwsP4Rx1CJsuhYTiAhvxjgW2R5FgStydiL/z2kokO++cJAtg7Ip/P1S/hwUv9tHOMg0GTSfqIV7SGpsabLreAMoVFY4uy2IwVGPWS/fUCE7WZUDPUEVeLY1Q/4c2GsCycv+2eorxR0OU43aOlLqDEZg63SX6vWH4Yu3OMR/+c1WA+dcQQIMbYdK96z11MPg9KhsKjiitHIvA5Lbc5xxYi9foAVRGnclgjBzD0KhkhVNn4wFmERYbJMsb/eoUMF3o6cFL3bd7L+NEx7Q2ms5PMfFAAu5sTU6miT8XKX3bc8JkW7HZb5r9m8HMSD0GAxuyYxUf/aLEWpPTLbKEE86bHru5/ubtEvBCLPOJ9KV0= stitsyuk@vm2"
  description = "ssh-keygen -t ed25519"
}

