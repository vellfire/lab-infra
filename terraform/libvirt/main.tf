resource "libvirt_volume" "debian-template" {
    name    = "bookworm.qcow2"
    pool    = "images"
    source  = "https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-genericcloud-amd64-daily.qcow2"
    format  = "qcow2"
}

resource "libvirt_volume" "deb-wkr-os" {
    name            = "debwkr${count.index + 1}.qcow2"
    count           = var.wkr_count
    pool            = "images"
    size            = 16 * 1024 * 1024 * 1024
    format          = "qcow2"
    base_volume_id  = libvirt_volume.debian-template.id
}

resource "libvirt_cloudinit_disk" "deb-wkr-init" {
    name        = "debwkr${count.index + 1}-init.iso"
    pool        = "default"
    count       = var.wkr_count
    user_data   = "#cloud-config\n${yamlencode({
        hostname = "debwkr${count.index + 1}"
        timezone = "Europe/London"
        users = [{
            name = var.standard_user_name,
            ssh_import_id = [
                var.git_ssh_keys,
            ]
            shell = "/bin/bash",
            sudo = "ALL=(ALL) NOPASSWD:ALL",
        },
        {
            name = var.automation_user_name,
            uid = var.automation_user_id,
            ssh_import_id = [
                var.git_ssh_keys,
            ]
            shell = "/bin/bash",
            sudo = "ALL=(ALL) NOPASSWD:ALL",
        }],
        package_update = true,
        package_upgrade = true,
        packages = [
            "qemu-guest-agent"
        ],
        runcmd = [
            "systemctl enable --now qemu-guest-agent"
        ]
    })}"

    network_config  = "#cloud-config\n${yamlencode({
        version = 2,
        ethernets = {
            ens3 = {
                dhcp4 = true,
                dhcp4-overrides = {
                    hostname = "debwkr${count.index + 1}"
                    use-dns = true,
                    use-ntp = true,
                    send-hostname = true,
                    use-routes = true,
                    use-domains = true,
                }
                accept-ra = true
                dhcp6 = false
            }
        }
    })}"
}

resource "macaddress" "vm_mac" {
    prefix = [52, 54, 00]
}

resource "libvirt_domain" "deb-wkr" {
    name                  = "debwkr${count.index + 1}"
    count                 = var.wkr_count
    memory                = 2048
    vcpu                  = 2
    autostart             = true
    arch                  = "x86_64"
    qemu_agent            = true
    cloudinit             = libvirt_cloudinit_disk.deb-wkr-init[count.index].id

    firmware              = "/usr/share/OVMF/OVMF_CODE_4M.fd"

    cpu {
        mode              = "custom"
    }

    disk {
        volume_id         = libvirt_volume.deb-wkr-os[count.index].id
    }

    boot_device {
        dev = [ "hd", "cdrom" , "network"]
    }

    network_interface {
        bridge            = "vmbr0"
        mac               = upper(macaddress.vm_mac.address)
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
