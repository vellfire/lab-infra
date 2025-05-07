variable "libvirt_uri" {
    description = "Libvirt uri"
    type        = string
    default     = "qemu+ssh://will@kvm1/system"
}

variable "wkr_count" {
    description = "Number of workers"
    type        = number
    default     = 3
}

variable "standard_user_name" {
    description = "Standard user"
    type        = string
    default     = "will"
}

variable "automation_user_name" {
    description = "Automation user name"
    type        = string
    default     = "automation"
}

variable "automation_user_id" {
    description = "Automation user id"
    type        = number
    default     = 1337
} 

variable "git_ssh_keys" {
    description = "Github ssh keys to import"
    type        = string
    default     = "gh:vellfire"
}
