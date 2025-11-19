terraform {
  required_version = "~> 1.14.0"
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "1.0.0"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}

provider "incus" {
  project = "default"
}
