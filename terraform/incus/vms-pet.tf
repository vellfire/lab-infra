variable "vm_pet_cfg" {
  type = map(object({
    host   = string
    cpus   = number
    memory = string
    vlan   = optional(number)
  }))
  default = {
    "vdb1"     = { host = "kvm2", cpus = 4, memory = "8GiB" }
    "vpod"     = { host = "kvm2", cpus = 4, memory = "8GiB" }
    "vws1"     = { host = "kvm2", cpus = 2, memory = "4GiB" }
    "run1"     = { host = "kvm1", cpus = 2, memory = "4GiB" }
    "run2"     = { host = "kvm2", cpus = 2, memory = "4GiB" }
    "dns1"     = { host = "kvm1", cpus = 2, memory = "4GiB" }
    "dns2"     = { host = "kvm2", cpus = 2, memory = "4GiB" }
  }
}

resource "macaddress" "vm_pet_mac_eth0" {
  for_each = var.vm_pet_cfg
  prefix   = [16, 102, 106]
}

module "vm_pet" {
  source   = "./modules/incus-vm"
  for_each = var.vm_pet_cfg

  name              = each.key
  host              = each.value.host
  cpus              = each.value.cpus
  memory            = each.value.memory
  vlan              = each.value.vlan
  parent_nic        = "nic0"
  mac_address       = macaddress.vm_pet_mac_eth0[each.key].address
  image_fingerprint = module.ubuntu_stable_image.fingerprints[each.value.host]

  cloud_init_user_data = templatefile(
    "${path.module}/templates/vms-pet/user-data.tftpl",
    {
      name                = each.key,
      timezone            = var.vm_timezone,
      standard_username   = var.standard_username,
      standard_ssh_key    = var.standard_ssh_key,
      automation_username = var.automation_username,
      automation_uid      = var.automation_uid,
      automation_ssh_key  = var.automation_ssh_key,
      dad_username        = var.dad_username,
      dad_uid             = var.dad_uid,
      dad_ssh_key         = var.dad_ssh_key
    }
  )

  cloud_init_network_config = templatefile(
    "${path.module}/templates/vms-pet/network-config.tftpl",
    {
      name      = each.key,
      vlan1_mac = macaddress.vm_pet_mac_eth0[each.key].address,
    }
  )
}

output "pet_vms" {
  description = "Pet VMs"
  value = {
    for name, vm in module.vm_pet : name => {
      ipv4 = vm.ipv4_address
      ipv6 = vm.ipv6_address
      mac  = vm.mac_address
      host = var.vm_pet_cfg[name].host
    }
  }
}
