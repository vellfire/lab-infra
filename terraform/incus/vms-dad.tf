variable "vm_dad_cfg" {
  type = map(object({
    cpus   = number
    memory = string
  }))
  default = {
    "vws1" = { cpus = 4, memory = "4GiB" }
  }
}

resource "macaddress" "vm_dad_mac_vlan1" {
  for_each = var.vm_dad_cfg
  prefix   = [16, 102, 106]
}

resource "incus_storage_volume" "vm_dad_data" {
  for_each     = var.vm_dad_cfg
  name         = "${each.key}_data"
  pool         = "data"
  project      = "default"
  remote       = "kvm2"
  type         = "custom"
  content_type = "block"
  config = {
    "size" = "32GiB"
  }
  lifecycle {
    ignore_changes = [config["size"]]
  }
}

resource "incus_instance" "vm_dad" {
  for_each  = var.vm_dad_cfg
  name      = each.key
  project   = "default"
  remote    = "kvm2"
  type      = "virtual-machine"
  image     = incus_image.ubuntu-stable.fingerprint
  ephemeral = false

  wait_for {
    type = "agent"
  }

  lifecycle {
    ignore_changes = [image]
  }

  config = {
    "limits.cpu"    = each.value.cpus
    "limits.memory" = each.value.memory

    "agent.nic_config"    = true
    "security.secureboot" = false
    "boot.autostart"      = true

    "cloud-init.user-data" = templatefile(
      "${path.module}/templates/vms-dad/user-data.tftpl",
      {
        name                = each.key,
        timezone            = var.vm_timezone,
        standard_username   = var.standard_username,
        standard_ssh_key    = var.standard_ssh_key
        dad_username        = var.dad_username,
        dad_uid             = var.dad_uid
        dad_ssh_key         = var.dad_ssh_key,
        automation_username = var.automation_username,
        automation_uid      = var.automation_uid,
        automation_ssh_key  = var.automation_ssh_key
      }
    )
    "cloud-init.network-config" = templatefile(
      "${path.module}/templates/vms-dad/network-config.tftpl",
      {
        name      = each.key,
        vlan1_mac = macaddress.vm_dad_mac_vlan1[each.key].address,
    })
  }

  device {
    name = "${each.key}_os"
    type = "disk"
    properties = {
      "pool"          = "fast"
      "boot.priority" = "1"
      "path"          = "/"
      "size"          = "16GiB"
    }
  }

  device {
    name = "${each.key}_data"
    type = "disk"
    properties = {
      "pool"   = "data"
      "source" = incus_storage_volume.vm_dad_data[each.key].name
    }
  }

  device {
    name = "incusbr0"
    type = "nic"

    properties = {
      network = "incusbr0"
      hwaddr  = macaddress.vm_dad_mac_vlan1[each.key].address
    }
  }
}
