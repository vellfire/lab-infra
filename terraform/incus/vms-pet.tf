variable "vm_pet_cfg" {
  type = map(object({
    name   = string
    cpus   = number
    memory = string
  }))
  default = {
    "vdb1" = { name = "vdb1", cpus = 4, memory = "8GiB"}
    "vin1" = { name = "vin1", cpus = 2, memory = "2GiB"}
  }
}

resource "macaddress" "vm_pet_mac_vlan1" {
  for_each = var.vm_pet_cfg
  prefix   = [16, 102, 106]
}

resource "incus_storage_volume" "vm_pet_data" {
  for_each     = var.vm_pet_cfg
  name         = "${each.value.name}_data"
  pool         = incus_storage_pool.nvme1.name
  content_type = "block"
  config = {
    "size" = "32GiB"
  }
}

resource "incus_instance" "vm_pet" {
  for_each  = var.vm_pet_cfg
  name      = each.value.name
  type      = "virtual-machine"
  image     = incus_image.ubuntu-stable.fingerprint
  ephemeral = false

  wait_for {
    type = "agent"
  }

  config = {
    "limits.cpu"    = each.value.cpus
    "limits.memory" = each.value.memory

    "agent.nic_config"    = true
    "security.secureboot" = false
    "boot.autostart" = true

    "cloud-init.user-data" = templatefile(
      "${path.module}/templates/vms-pet/user-data.tftpl",
      {
        name                = each.value.name,
        timezone            = var.vm_timezone,
        standard_username   = var.standard_username,
        standard_ssh_key    = var.standard_ssh_key,
        automation_username = var.automation_username,
        automation_uid      = var.automation_uid,
        automation_ssh_key  = var.automation_ssh_key
      }
    )
    "cloud-init.network-config" = templatefile(
      "${path.module}/templates/vms-pet/network-config.tftpl",
      {
        name       = each.value.name,
        vlan1_mac  = macaddress.vm_pet_mac_vlan1[each.key].address,
    })
  }

  device {
    name = "${each.value.name}_os"
    type = "disk"
    properties = {
      "pool"          = "nvme0"
      "boot.priority" = "1"
      "path"          = "/"
      "size"          = "16GiB"
    }
  }

  device {
    name = "${each.value.name}_data"
    type = "disk"
    properties = {
      "pool"   = "nvme1"
      "source" = incus_storage_volume.vm_pet_data[each.key].name
    }
  }

  device {
    name = "incusbr0"
    type = "nic"

    properties = {
      network = "incusbr0"
      hwaddr  = macaddress.vm_pet_mac_vlan1[each.key].address
    }
  }
}
