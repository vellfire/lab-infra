terraform {
  required_version = ">= 1.13.0"
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = ">= 1.0.0"
    }
  }
}
