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

variable "standard_ssh_key" {
  description = "Will's SSH key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoqdhIBCfewaqLTKaWt0fF2oNPgR430pcpl4PkNWJ3w"
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

variable "automation_ssh_key" {
  description = "Automation SSH key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHxhWVzK0D0jpASF/TXwO7KtmnA95e9OFy55W6miLXd"
}
/*
variable "git_ssh_keys" {
  description = "GitHub ssh keys to import"
  type        = string
  default     = "gh:vellfire"
}
*/
variable "vm_wkr_name" {
  description = "VM name (for hostname and files)"
  type        = string
  default     = "vwkr"
}

variable "vm_wkr_count" {
  description = "Number of vms"
  type        = number
  default     = 0
}
/*
variable "vm_dad_name" {
  description = "VM name (for hostname and files)"
  type        = string
  default     = "wsrv"
}

variable "vm_dad_count" {
  description = "Number of vms"
  type        = number
  default     = 2
}
*/

variable "dad_username" {
  description = "Dad's user"
  type        = string
  default     = "john"
}

variable "dad_uid" {
  description = "Dad's user id"
  type        = number
  default     = 1338
}

variable "dad_ssh_key" {
  description = "Dad's SSH key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWaxv/zcvkQkj3O3VG8/qnc2CIi2SuZA8zJAmetfUMw"
}
