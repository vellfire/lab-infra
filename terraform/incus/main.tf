resource "incus_storage_pool" "nvme0" {
  name = "nvme0"
  project = "default"
  driver = "dir"
}

resource "incus_storage_pool" "nvme1" {
  name = "nvme1"
  project = "default"
  driver = "dir"
  config = {
    "source" = "/opt/virt"
  }
}

import {
  to = incus_storage_pool.nvme0
  id = "default/nvme0"
}

resource "incus_image" "ubuntu-stable" {
  source_image = {
    remote = "images"
    name = "ubuntu/24.04/cloud"
    type = "virtual-machine"
    architecture = "x86_64"
  }
}
