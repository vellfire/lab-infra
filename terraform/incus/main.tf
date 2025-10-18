resource "incus_image" "ubuntu-stable" {
  remote = "kvm2"
  source_image = {
    remote       = "images"
    name         = "ubuntu/24.04/cloud"
    type         = "virtual-machine"
    architecture = "x86_64"
  }
}
