resource "libvirt_volume" "deb-gc" {
    name   = "debian-gc-bookworm"
    pool   = "templates"
    source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    format = "qcow2"
}

resource "libvirt_volume" "deb-gc-worker" {
    name   = "deb-gc-${count.index}.qcow2"
    pool   = "images"
    size   = "21474836480"
    format = "qcow2"
    base_volume_id = libvirt_volume.deb-gc.id
    count = 1
}

