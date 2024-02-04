locals {
  ssh-key = file("~/.ssh/id_rsa.pub")
  metadata = {
    ssh-keys = "${var.admin}:${local.ssh-key}"
  }
}