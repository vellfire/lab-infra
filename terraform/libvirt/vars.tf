variable "libvirt_uri" {
    description = "Libvirt uri"
    type        = string
    default     = "qemu+ssh://will@kvm1/system?sshauth=privkey&no_verify=1"
}

variable "vm_name" {
    description = "VM name (for hostname and files)"
    type        = string
    default     = "debwkr"
}

variable "vm_count" {
    description = "Number of workers"
    type        = number
    default     = 3
}

variable "vm_template" {
    description = "Source template image"
    type        = string
    default     = "https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-genericcloud-amd64-daily.qcow2"
}

variable "vm_timezone" {
    description = "System timezone"
    type        = string
    default     = "Europe/London"
}

variable "vm_net_default" {
    description = "Default vm bridge"
    type        = string
    default     = "vmbr0"
}

# variable "vm_net_vlan50" {
#     description = "VLAN 50 bridge"
#     type        = string
#     default     = "vmbr50"
# }

# variable "vm_net_vlan998" {
#     description = "VLAN 998 bridge"
#     type        = string
#     default     = "vmbr998"
# }

variable "standard_username" {
    description = "Standard user"
    type        = string
    default     = "will"
}

variable "automation_username" {
    description = "Automation user name"
    type        = string
    default     = "automation"
}

variable "automation_uid" {
    description = "Automation user id"
    type        = number
    default     = 1337
} 

variable "git_ssh_keys" {
    description = "Github ssh keys to import"
    type        = string
    default     = "gh:vellfire"
}
