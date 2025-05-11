resource "libvirt_volume" "vm-template" {
    name    = "vm-template.qcow2"
    pool    = "templates"
    source  = var.vm_template
    format  = "qcow2"
}

resource "libvirt_volume" "vm-vol-os" {
    name            = "${var.vm_name}${count.index + 1}.qcow2"
    count           = var.vm_count
    pool            = "images"
    size            = 16 * 1024 * 1024 * 1024
    format          = "qcow2"
    base_volume_id  = libvirt_volume.vm-template.id
}

data template_file "vm_init_user_data" {
    template = file("${path.module}/templates/user-data.yml")
    count = var.vm_count
    vars = {
        hostname = "${var.vm_name}${count.index + 1}"
        timezone = var.vm_timezone
        standard_username = var.standard_username
        automation_username = var.automation_username
        automation_uid = var.automation_uid
        ssh_keys = var.git_ssh_keys
    }
}

data template_file "vm_init_network_config" {
    template = file("${path.module}/templates/network-config.yml")
    count = var.vm_count
    vars = {
        hostname = "${var.vm_name}${count.index + 1}"
    }
}

resource "libvirt_cloudinit_disk" "vm-init" {
    name        = "${var.vm_name}${count.index + 1}-init.iso"
    pool        = "iso"
    count       = var.vm_count
    user_data   = data.template_file.vm_init_user_data[count.index].rendered
    network_config = data.template_file.vm_init_network_config[count.index].rendered
}

resource "macaddress" "vm-mac" {
    count = var.vm_count
    prefix = [52, 54, 0]
}

resource "libvirt_domain" "vm-def" {
    name                  = "${var.vm_name}${count.index + 1}"
    count                 = var.vm_count
    memory                = 2048
    vcpu                  = 2
    autostart             = true
    arch                  = "x86_64"
    qemu_agent            = true
    cloudinit             = libvirt_cloudinit_disk.vm-init[count.index].id

    firmware              = "/usr/share/OVMF/OVMF_CODE_4M.fd"

    cpu {
        mode              = "custom"
    }

    disk {
        volume_id         = libvirt_volume.vm-vol-os[count.index].id
    }

    boot_device {
        dev = [ "hd", "cdrom" , "network"]
    }

    network_interface {
        bridge            = var.vm_net_default
        mac               = macaddress.vm-mac[count.index].address
    }

    graphics {
        type              = "vnc"
        listen_type       = "address"
        autoport          = true
    }

    video {
        type              = "vga"
    }

    console {
        type = "pty"
        target_port = 0
        target_type = "serial"
    }

    console {
        type = "pty"
        target_port = 1
        target_type = "virtio"
    }
}
