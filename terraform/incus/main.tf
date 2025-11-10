locals {
  incus_hosts = toset(["kvm1", "kvm2"])
}

module "ubuntu_stable_image" {
  source = "./modules/incus-image"

  hosts      = local.incus_hosts
  image_name = "ubuntu/24.04/cloud"
}
