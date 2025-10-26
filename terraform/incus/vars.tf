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

/* K8s */

variable "k8s_enabled" {
  description = "Enable Kubernetes cluster VMs"
  type        = bool
  default     = true
}

variable "k8s_worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 2
}

/* K8s Control Plane */

variable "k8s_control_cpu" {
  description = "Control plane CPUs"
  type        = number
  default     = 2
}

variable "k8s_control_memory" {
  description = "Control plane memory"
  type        = string
  default     = "8GiB"
}

variable "k8s_control_os_size" {
  description = "Control plane OS disk"
  type        = string
  default     = "32GiB"
}

variable "k8s_control_data_size" {
  description = "Control plane data disk"
  type        = string
  default     = "20GiB"
}

/* K8s Workers */

variable "k8s_worker_cpu" {
  description = "CPU cores per Kubernetes worker"
  type        = number
  default     = 2
}

variable "k8s_worker_memory" {
  description = "Memory per Kubernetes worker"
  type        = string
  default     = "4GiB"
}

variable "k8s_worker_os_size" {
  description = "OS disk size per worker"
  type        = string
  default     = "32GiB"
}

variable "k8s_worker_data_size" {
  description = "Data disk size per worker (container storage)"
  type        = string
  default     = "64GiB"
}
