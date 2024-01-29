output "vm_external_ip" {
  description = "External IP address of instances"
  value = {
    instance_name1 = yandex_compute_instance.platform.name
    external_ip1 = yandex_compute_instance.platform.network_interface.0.nat_ip_address
    instance_name2 = yandex_compute_instance.platform-db.name
    external_ip2 = yandex_compute_instance.platform-db.network_interface.0.nat_ip_address
  }
}
