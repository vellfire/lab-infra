terraform {
  required_version = "~> 1.13.0"
  required_providers {
    incus = {
      source = "lxc/incus"
      version = "0.5.1"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}

provider "incus" {}
