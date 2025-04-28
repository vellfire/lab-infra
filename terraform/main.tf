resource "libvirt_volume" "deb-gc" {
    name                  = "debian-gc-bookworm.qcow2"
    pool                  = "images"
    source                = "https://files.int.mcda.dev/debian-12-genericcloud-amd64.qcow2"
    format                = "qcow2"
}

resource "libvirt_volume" "deb-gc-worker" {
    name                  = "deb-gc-${count.index}.qcow2"
    count                 = var.worker_count
    pool                  = "images"
    size                  = "17179869184" # 16 GB
    format                = "qcow2"
    base_volume_id        = libvirt_volume.deb-gc.id
}

resource "libvirt_domain" "default" {
    name                  = "deb-gc-${count.index}"
    count                 = var.worker_count
    memory                = 2048
    vcpu                  = 2
    autostart             = true
    arch                  = "x86_64"

    cpu {
        mode              = "custom"
    }
    
    disk {
        volume_id         = libvirt_volume.deb-gc-worker[count.index].id
    }
    
    network_interface {
        network_name      = "lan"
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
        type              = "pty"
        target_port       = "0"
        target_type       = "serial"
    }
}
