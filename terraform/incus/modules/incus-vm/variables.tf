variable "name" {
  description = "VM name"
  type        = string
}

variable "host" {
  description = "Incus remote host"
  type        = string
}

variable "image_fingerprint" {
  description = "Image fingerprint"
  type        = string
}


variable "cpus" {
  description = "CPU cores"
  type        = number
}

variable "memory" {
  description = "Memory size"
  type        = string
}


variable "os_disk_size" {
  description = "OS disk size"
  type        = string
  default     = "16GiB"
}

variable "data_disk_size" {
  description = "Data disk size"
  type        = string
  default     = "32GiB"
}

variable "storage_pool_os" {
  description = "OS disk storage pool"
  type        = string
  default     = "fast"
}

variable "storage_pool_data" {
  description = "Data disk storage pool"
  type        = string
  default     = "data"
}

# Network
variable "parent_nic" {
  description = "Parent NIC for SR-IOV"
  type        = string
}

variable "vlan" {
  description = "VLAN ID"
  type        = number
  default     = null
}

variable "mac_prefix" {
  description = "MAC address prefix"
  type        = list(number)
  default     = [16, 102, 106]
}

variable "mac_address" {
  description = "Pre-generated MAC address"
  type        = string
  default     = null
}

# Cloud-init
variable "cloud_init_user_data" {
  description = "Cloud-init user-data"
  type        = string
}

variable "cloud_init_network_config" {
  description = "Cloud-init network-config"
  type        = string
}


variable "project" {
  description = "Incus project"
  type        = string
  default     = "default"
}

variable "ephemeral" {
  description = "Ephemeral VM"
  type        = bool
  default     = false
}

variable "boot_autostart" {
  description = "Autostart on boot"
  type        = bool
  default     = true
}

variable "secureboot" {
  description = "Enable secure boot"
  type        = bool
  default     = false
}
