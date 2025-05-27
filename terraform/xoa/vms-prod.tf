resource "macaddress" "prod_vm_mac" {
  count  = var.prod_vm_count
  prefix = [82, 84, 0] # 52:54:00 (KVM)
}

resource "xenorchestra_cloud_config" "prod_user" {
  count = var.prod_vm_count
  name  = "${var.prod_vm_name}${count.index}_user"
  template = templatefile("${path.module}/templates/vms-prod/user-data.tftpl", {
    hostname            = "${var.prod_vm_name}${count.index + 1}",
    timezone            = var.vm_timezone,
    standard_username   = var.standard_username,
    automation_username = var.automation_username,
    automation_uid      = var.automation_uid,
    ssh_keys            = var.git_ssh_keys
  })
}

resource "xenorchestra_cloud_config" "prod_net" {
  count = var.prod_vm_count
  name  = "${var.prod_vm_name}${count.index}_net"
  template = templatefile("${path.module}/templates/vms-prod/network-config.tftpl", {
    hostname = "${var.prod_vm_name}${count.index + 1}"
    mac      = macaddress.prod_vm_mac[count.index].address
  })
}

resource "xenorchestra_vm" "prod-vms" {
  count            = var.prod_vm_count
  name_label       = "${var.prod_vm_name}${count.index + 1}"
  name_description = "Managed by TF"

  template             = data.xenorchestra_template.debian12base.id
  cloud_config         = xenorchestra_cloud_config.prod_user[count.index].template
  cloud_network_config = xenorchestra_cloud_config.prod_net[count.index].template

  auto_poweron      = true
  exp_nested_hvm    = false
  high_availability = "best-effort"
  wait_for_ip       = true

  cpus              = 2
  memory_max        = 2 * 1024 * 1024 * 1024
  hvm_boot_firmware = "uefi"

  network {
    network_id  = data.xenorchestra_network.xng1.id
    mac_address = macaddress.prod_vm_mac[count.index].address
  }

  disk {
    name_label = "${var.prod_vm_name}${count.index + 1}_os"
    sr_id      = data.xenorchestra_sr.xng1.id
    size       = 16 * 1024 * 1024 * 1024
  }

  disk {
    name_label = "${var.prod_vm_name}${count.index + 1}_data"
    sr_id      = data.xenorchestra_sr.xng1.id
    size       = 32 * 1024 * 1024 * 1024
  }
}

resource "xenorchestra_vm" "opnsense_vm" {
  name_label       = "xnfw1"
  name_description = "Managed by TF"

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
