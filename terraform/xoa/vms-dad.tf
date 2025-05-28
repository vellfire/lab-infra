resource "macaddress" "vm_dad_mac" {
  count  = var.vm_dad_count
  prefix = [82, 84, 0] # 52:54:00 (KVM)
}

resource "xenorchestra_cloud_config" "vm_dad_user" {
  count = var.vm_dad_count
  name  = "${var.vm_dad_name}${count.index + 1}_user"
  template = templatefile("${path.module}/templates/vms_dad/user-data.tftpl", {
    name                = "${var.vm_dad_name}${count.index + 1}",
    timezone            = var.vm_timezone,
    standard_username   = var.standard_username,
    dad_username        = var.dad_username,
    dad_ssh_key         = var.dad_ssh_key,
    automation_username = var.automation_username,
    automation_uid      = var.automation_uid,
    ssh_keys            = var.git_ssh_keys
  })
}

resource "xenorchestra_cloud_config" "vm_dad_net" {
  count = var.vm_dad_count
  name  = "${var.vm_dad_name}${count.index + 1}_net"
  template = templatefile("${path.module}/templates/vms_dad/network-config.tftpl", {
    hostname = "${var.vm_dad_name}${count.index + 1}"
    mac      = macaddress.vm_dad_mac[count.index].address
  })
}

resource "xenorchestra_vm" "vm_dad" {
  count            = var.vm_dad_count
  name_label       = "${var.vm_dad_name}${count.index + 1}"
  name_description = "Managed by TF"
  tags             = "web"

  template             = data.xenorchestra_template.debian12base.id
  cloud_config         = xenorchestra_cloud_config.vm_dad_user[count.index].template
  cloud_network_config = xenorchestra_cloud_config.vm_dad_net[count.index].template

  auto_poweron      = true
  exp_nested_hvm    = false
  high_availability = "best-effort"
  wait_for_ip       = true

  cpus              = 2
  memory_max        = 2 * 1024 * 1024 * 1024
  hvm_boot_firmware = "uefi"

  network {
    network_id  = data.xenorchestra_network.xng1.id
    mac_address = macaddress.vm_dad_mac[count.index].address
  }

  disk {
    name_label = "${var.vm_dad_name}${count.index + 1}_os"
    sr_id      = data.xenorchestra_sr.xng1.id
    size       = 16 * 1024 * 1024 * 1024
  }

  disk {
    name_label = "${var.vm_dad_name}${count.index + 1}_data"
    sr_id      = data.xenorchestra_sr.xng1.id
    size       = 32 * 1024 * 1024 * 1024
  }
  /*
  lifecycle {
    prevent_destroy = true
  }
*/
}
