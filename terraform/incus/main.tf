resource "incus_storage_pool" "nvme0" {
  name    = "nvme0"
  project = "default"
  remote  = "kvm1"
  driver  = "dir"
}

import {
  to = incus_storage_pool.nvme0
  id = "kvm1:default/nvme0"
}

resource "incus_storage_pool" "nvme1" {
  name    = "nvme1"
  project = "default"
  remote  = "kvm1"
  driver  = "dir"
  config = {
    "source" = "/opt/virt"
  }
}

import {
  to = incus_storage_pool.nvme1
  id = "kvm1:default/nvme1"
}

resource "incus_image" "ubuntu-stable" {
  source_image = {
    remote       = "images"
    name         = "ubuntu/24.04/cloud"
    type         = "virtual-machine"
    architecture = "x86_64"
  }
}
