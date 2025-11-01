resource "macaddress" "vm_mac" {
  count  = var.generate_mac ? 1 : 0
  prefix = var.mac_prefix
}

locals {
  mac_address = var.generate_mac ? macaddress.vm_mac[0].address : var.mac_address
}

resource "incus_storage_volume" "vm_data" {
  name         = "${var.name}_data"
  pool         = var.storage_pool_data
  project      = var.project
  remote       = var.host
  type         = "custom"
  content_type = "block"

  config = {
    "size" = var.data_disk_size
  }

  lifecycle {
    ignore_changes = [config["size"]]
  }
}

resource "incus_instance" "vm" {
  name      = var.name
  project   = var.project
  remote    = var.host
  type      = "virtual-machine"
  image     = var.image_fingerprint
  ephemeral = var.ephemeral

  wait_for {
    type = "ipv4"
    nic  = "eth0"
  }

  wait_for {
    type = "ipv6"
    nic  = "eth0"
  }

  lifecycle {
    ignore_changes = [image]
  }

  config = {
    "limits.cpu"    = var.cpus
    "limits.memory" = var.memory

    "agent.nic_config"    = true
    "security.secureboot" = var.secureboot
    "boot.autostart"      = var.boot_autostart

    "cloud-init.user-data"      = var.cloud_init_user_data
    "cloud-init.network-config" = var.cloud_init_network_config
  }

  # OS disk
  device {
    name = "${var.name}_os"
    type = "disk"
    properties = {
      "pool"          = var.storage_pool_os
      "boot.priority" = "1"
      "path"          = "/"
      "size"          = var.os_disk_size
    }
  }

  # Data disk
  device {
    name = "${var.name}_data"
    type = "disk"
    properties = {
      "pool"   = var.storage_pool_data
      "source" = incus_storage_volume.vm_data.name
    }
  }

  # Network interface
  device {
    name = "eth0"
    type = "nic"

    properties = merge(
      {
        nictype = "sriov"
        parent  = var.parent_nic
        hwaddr  = local.mac_address
      },
      var.vlan != null ? { vlan = var.vlan } : {}
    )
  }
}
