variable "vm_pet_cfg" {
  type = map(object({
    name       = string
    cpus       = number
    memory_max = number
    vlan50     = bool
  }))
  default = {
    "dl1" = { name = "dl1", cpus = 2, memory_max = 2048, vlan50 = true }
  }
}

resource "macaddress" "vm_pet_mac_vlan1" {
  for_each = var.vm_pet_cfg
  prefix   = [82, 84, 0] # 52:54:00 (KVM)
}

resource "macaddress" "vm_pet_mac_vlan50" {
  for_each = var.vm_pet_cfg
  prefix   = [82, 84, 0] # 52:54:00 (KVM)
}

resource "xenorchestra_cloud_config" "vm_pet_user" {
  for_each = var.vm_pet_cfg
  name     = "${each.value.name}_user"
  template = templatefile("${path.module}/templates/vms-pet/user-data.tftpl", {
    name                = each.key,
    timezone            = var.vm_timezone,
    standard_username   = var.standard_username,
    automation_username = var.automation_username,
    automation_uid      = var.automation_uid,
    ssh_keys            = var.git_ssh_keys
  })
}

resource "xenorchestra_cloud_config" "vm_pet_net" {
  for_each = var.vm_pet_cfg
  name     = "${each.value.name}_net"
  template = templatefile("${path.module}/templates/vms-pet/network-config.tftpl", {
    name       = each.value.name
    vlan1_mac  = macaddress.vm_pet_mac_vlan1[each.key].address
    vlan50     = each.value.vlan50
    vlan50_mac = macaddress.vm_pet_mac_vlan50[each.key].address
  })
}

resource "xenorchestra_vm" "vm_pet" {
  for_each         = var.vm_pet_cfg
  name_label       = each.value.name
  name_description = "Managed by TF"

  template             = data.xenorchestra_template.debian12base.id
  cloud_config         = xenorchestra_cloud_config.vm_pet_user[each.key].template
  cloud_network_config = xenorchestra_cloud_config.vm_pet_net[each.key].template

  auto_poweron      = true
  exp_nested_hvm    = false
  high_availability = "best-effort"
  wait_for_ip       = true

  cpus              = each.value.cpus
  memory_max        = each.value.memory_max * 1024 * 1024
  hvm_boot_firmware = "uefi"

  network {
    network_id  = data.xenorchestra_network.xng1.id
    mac_address = macaddress.vm_pet_mac_vlan1[each.key].address
  }

  dynamic "network" {
    for_each = each.value.vlan50 ? [true] : [false]
    content {
      network_id  = xenorchestra_network.xng1vlan50.id
      mac_address = macaddress.vm_pet_mac_vlan50[each.key].address
    }
  }

  disk {
    name_label = "{each.key}_os"
    sr_id      = data.xenorchestra_sr.xng1.id
    size       = 16 * 1024 * 1024 * 1024
  }

  disk {
    name_label = "{each.key}_data"
    sr_id      = data.xenorchestra_sr.xng1.id
    size       = 32 * 1024 * 1024 * 1024
  }
}

resource "xenorchestra_vm" "opnsense_vm" {
  name_label       = "xnfw1"
  name_description = "Managed by TF"
  tags             = ["network"]

  auto_poweron      = true
  exp_nested_hvm    = false
  high_availability = "best-effort"
  wait_for_ip       = false

  template = data.xenorchestra_template.opnsense_template.id

  cpus              = 1
  memory_max        = 1 * 1024 * 1024 * 1024
  hvm_boot_firmware = "uefi"

  network {
    network_id  = xenorchestra_network.xng1vlan998.id
    mac_address = "52:54:00:42:d6:52"
  }

  network {
    network_id  = xenorchestra_network.xng1vlan50.id
    mac_address = "52:54:00:45:13:e3"
  }

  network {
    network_id  = xenorchestra_network.xng1vlan240.id
    mac_address = "52:54:00:22:c1:30"
  }

  disk {
    name_label = "xnfw1"
    sr_id      = data.xenorchestra_sr.xng1.id
    size       = 16 * 1024 * 1024 * 1024
  }
}
