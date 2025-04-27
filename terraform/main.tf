terraform {
    required_providers {
        libvirt = {
            source  = "dmacvicar/libvirt"
            version = "0.8.3"
        }
    }
}

resource "libvirt_volume" "debian-cloud" {
    name   = "debian-bookworm"
    pool   = "templates"
    source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    format = "qcow2"
}
