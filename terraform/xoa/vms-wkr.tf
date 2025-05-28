resource "macaddress" "vm_wkr_mac_vlan1" {
  count  = var.vm_wkr_count
  prefix = [82, 84, 0] # 52:54:00 (KVM)
}

resource "xenorchestra_cloud_config" "vm_wkr_user" {
  count = var.vm_wkr_count
  name  = "${var.vm_wkr_name}${count.index + 1}_user"
  template = templatefile("${path.module}/templates/vms_wkr/user-data.tftpl", {
    name                = "${var.vm_wkr_name}${count.index + 1}",
    timezone            = var.vm_timezone,
    standard_username   = var.standard_username,
    automation_username = var.automation_username,
    automation_uid      = var.automation_uid,
    ssh_keys            = var.git_ssh_keys
  })
}

resource "xenorchestra_cloud_config" "vm_wkr_net" {
  count = var.vm_wkr_count
  name  = "${var.vm_wkr_name}${count.index + 1}_net"
  template = templatefile("${path.module}/templates/vms_wkr/network-config.tftpl", {
    hostname = "${var.vm_wkr_name}${count.index + 1}"
    mac      = macaddress.vm_wkr_mac_vlan1[count.index].address
  })
}

resource "xenorchestra_vm" "vm_wkr" {
  count            = var.vm_wkr_count
  name_label       = "${var.vm_wkr_name}${count.index + 1}"
  name_description = "Managed by TF"

  template             = data.xenorchestra_template.debian12base.id
  cloud_config         = xenorchestra_cloud_config.vm_wkr_user[count.index].template
  cloud_network_config = xenorchestra_cloud_config.vm_wkr_net[count.index].template

  auto_poweron      = true
  exp_nested_hvm    = false
  high_availability = "best-effort"
  wait_for_ip       = true

  cpus              = 2
  memory_max        = 2048 * 1024 * 1024
  hvm_boot_firmware = "uefi"

  network {
    network_id  = data.xenorchestra_network.xng1.id
    mac_address = macaddress.vm_wkr_mac_vlan1[count.index].address
  }

  disk {
    name_label = "${var.vm_wkr_name}${count.index + 1}_os"
    sr_id      = data.xenorchestra_sr.xng1.id
    size       = 16 * 1024 * 1024 * 1024
  }

  disk {
    name_label = "${var.vm_wkr_name}${count.index + 1}_data"
    sr_id      = data.xenorchestra_sr.xng1.id
    size       = 32 * 1024 * 1024 * 1024
  }
}
