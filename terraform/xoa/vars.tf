variable "vm_timezone" {
  description = "System timezone"
  type        = string
  default     = "Europe/London"
}

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
  description = "GitHub ssh keys to import"
  type        = string
  default     = "gh:vellfire"
}

variable "prod_vm_name" {
  description = "VM name (for hostname and files)"
  type        = string
  default     = "xnvm"
}

variable "prod_vm_count" {
  description = "Number of vms"
  type        = number
  default     = 1
}

variable "dad_vm_name" {
  description = "VM name (for hostname and files)"
  type        = string
  default     = "wsrv"
}

variable "dad_vm_count" {
  description = "Number of vms"
  type        = number
  default     = 2
}

variable "dad_username" {
  description = "Dad's user"
  type        = string
  default     = "john"
}

variable "dad_ssh_key" {
  description = "Dad's SSH key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWaxv/zcvkQkj3O3VG8/qnc2CIi2SuZA8zJAmetfUMw"
}
