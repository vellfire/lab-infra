terraform {
  required_version = "~> 1.13.0"
  required_providers {
    xenorchestra = {
      source  = "terra-farm/xenorchestra"
      version = "0.26.1"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}

provider "xenorchestra" {}
