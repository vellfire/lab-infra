resource "macaddress" "vm_wkr_mac_vlan1" {
  count  = var.vm_wkr_count
  prefix = [16, 102, 106] # 10:66:6a
}

resource "incus_storage_volume" "vm_wkr_data" {
  count        = var.vm_wkr_count
  name         = "${var.vm_wkr_name}${count.index + 1}_data"
  pool         = "nvme1"
  project      = "default"
  type         = "custom"
  content_type = "block"
  config = {
    "size" = "32GiB"
  }
  lifecycle {
    ignore_changes = [config["size"]]
  }
}

resource "incus_instance" "vm_wkr" {
  count     = var.vm_wkr_count
  name      = "${var.vm_wkr_name}${count.index + 1}"
  project   = "default"
  type      = "virtual-machine"
  image     = incus_image.ubuntu-stable.fingerprint
  ephemeral = false

  wait_for {
    type = "agent"
  }

  config = {
    "limits.cpu"    = 2
    "limits.memory" = "4GiB"

    "agent.nic_config"    = true
    "security.secureboot" = false
    "boot.autostart"      = true

    "cloud-init.user-data" = templatefile(
      "${path.module}/templates/vms-wkr/user-data.tftpl",
      {
        name                = "${var.vm_wkr_name}${count.index + 1}",
        timezone            = var.vm_timezone,
        standard_username   = var.standard_username,
        standard_ssh_key    = var.standard_ssh_key,
        automation_username = var.automation_username,
        automation_uid      = var.automation_uid,
        automation_ssh_key  = var.automation_ssh_key
      }
    )
    "cloud-init.network-config" = templatefile(
      "${path.module}/templates/vms-wkr/network-config.tftpl",
      {
        name = "${var.vm_wkr_name}${count.index + 1}",
        mac  = macaddress.vm_wkr_mac_vlan1[count.index].address
    })
  }

  device {
    name = "${var.vm_wkr_name}${count.index + 1}_os"
    type = "disk"
    properties = {
      "pool"          = "nvme0"
      "boot.priority" = "1"
      "path"          = "/"
      "size"          = "16GiB"
    }
  }

  device {
    name = "${var.vm_wkr_name}${count.index + 1}_data"
    type = "disk"
    properties = {
      "pool"   = "nvme1"
      "source" = incus_storage_volume.vm_wkr_data[count.index].name
    }
  }

  device {
    name = "incusbr0"
    type = "nic"

    properties = {
      nictype = "bridged"
      parent  = "br0"
      hwaddr  = macaddress.vm_wkr_mac_vlan1[count.index].address
    }
  }
}
