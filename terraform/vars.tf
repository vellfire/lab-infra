variable "libvirt_uri" {
    description = "Libvirt URI"
    type        = string
    default     = "qemu+ssh://will@kvm1/system"
}

variable "worker_count" {
    description = "Number of workers"
    type        = number
    default     = 3
}
