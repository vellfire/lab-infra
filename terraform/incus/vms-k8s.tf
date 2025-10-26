locals {
  k8s_control_count = var.k8s_enabled ? 1 : 0
  k8s_worker_count  = var.k8s_enabled ? var.k8s_worker_count : 0
}

resource "macaddress" "vm_k8s_control_mac_vlan1" {
  count  = local.k8s_control_count
  prefix = [16, 102, 106]
}

resource "incus_storage_volume" "vm_k8s_control_data" {
  count        = local.k8s_control_count
  name         = "k8s-control_data"
  pool         = "data"
  project      = "default"
  remote       = "kvm2"
  type         = "custom"
  content_type = "block"
  config = {
    "size" = var.k8s_control_data_size
  }
  lifecycle {
    ignore_changes = [config["size"]]
  }
}

resource "incus_instance" "vm_k8s_control" {
  count     = local.k8s_control_count
  name      = "k8s-control"
  project   = "default"
  remote    = "kvm2"
  type      = "virtual-machine"
  image     = incus_image.ubuntu-stable.fingerprint
  ephemeral = false

  wait_for {
    type = "agent"
  }

  config = {
    "limits.cpu"    = var.k8s_control_cpu
    "limits.memory" = var.k8s_control_memory

    "agent.nic_config"    = true
    "security.secureboot" = false
    "boot.autostart"      = true

    "cloud-init.user-data" = templatefile(
      "${path.module}/templates/vms-k8s/user-data.tftpl",
      {
        name                = "k8s-control",
        node_type           = "control",
        timezone            = var.vm_timezone,
        standard_username   = var.standard_username,
        standard_ssh_key    = var.standard_ssh_key,
        automation_username = var.automation_username,
        automation_uid      = var.automation_uid,
        automation_ssh_key  = var.automation_ssh_key
      }
    )
    "cloud-init.network-config" = templatefile(
      "${path.module}/templates/vms-k8s/network-config.tftpl",
      {
        name = "k8s-control",
        mac  = macaddress.vm_k8s_control_mac_vlan1[0].address
    })
  }

  device {
    name = "k8s-control_os"
    type = "disk"
    properties = {
      "pool"          = "fast"
      "boot.priority" = "1"
      "path"          = "/"
      "size"          = var.k8s_control_os_size
    }
  }

  device {
    name = "k8s-control_data"
    type = "disk"
    properties = {
      "pool"   = "data"
      "source" = incus_storage_volume.vm_k8s_control_data[0].name
    }
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype = "sriov"
      parent  = "nic1"
      vlan    = "114"
      hwaddr  = macaddress.vm_k8s_control_mac_vlan1[0].address
    }
  }
}

/* Workers */

resource "macaddress" "vm_k8s_worker_mac_vlan1" {
  count  = local.k8s_worker_count
  prefix = [16, 102, 106]
}

resource "incus_storage_volume" "vm_k8s_worker_data" {
  count        = local.k8s_worker_count
  name         = "k8s-worker${count.index + 1}_data"
  pool         = "data"
  project      = "default"
  remote       = "kvm2"
  type         = "custom"
  content_type = "block"
  config = {
    "size" = var.k8s_worker_data_size
  }
  lifecycle {
    ignore_changes = [config["size"]]
  }
}

resource "incus_instance" "vm_k8s_worker" {
  count     = local.k8s_worker_count
  name      = "k8s-worker${count.index + 1}"
  project   = "default"
  remote    = "kvm2"
  type      = "virtual-machine"
  image     = incus_image.ubuntu-stable.fingerprint
  ephemeral = false

  wait_for {
    type = "agent"
  }

  config = {
    "limits.cpu"    = var.k8s_worker_cpu
    "limits.memory" = var.k8s_worker_memory

    "agent.nic_config"    = true
    "security.secureboot" = false
    "boot.autostart"      = true

    "cloud-init.user-data" = templatefile(
      "${path.module}/templates/vms-k8s/user-data.tftpl",
      {
        name                = "k8s-worker${count.index + 1}",
        node_type           = "worker",
        timezone            = var.vm_timezone,
        standard_username   = var.standard_username,
        standard_ssh_key    = var.standard_ssh_key,
        automation_username = var.automation_username,
        automation_uid      = var.automation_uid,
        automation_ssh_key  = var.automation_ssh_key
      }
    )
    "cloud-init.network-config" = templatefile(
      "${path.module}/templates/vms-k8s/network-config.tftpl",
      {
        name = "k8s-worker${count.index + 1}",
        mac  = macaddress.vm_k8s_worker_mac_vlan1[count.index].address
    })
  }

  device {
    name = "k8s-worker${count.index + 1}_os"
    type = "disk"
    properties = {
      "pool"          = "fast"
      "boot.priority" = "1"
      "path"          = "/"
      "size"          = var.k8s_worker_os_size
    }
  }

  device {
    name = "k8s-worker${count.index + 1}_data"
    type = "disk"
    properties = {
      "pool"   = "data"
      "source" = incus_storage_volume.vm_k8s_worker_data[count.index].name
    }
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype = "sriov"
      parent  = "nic1"
      vlan    = "114"
      hwaddr  = macaddress.vm_k8s_worker_mac_vlan1[count.index].address
    }
  }
}

output "k8s_control_ip" {
  description = "Kubernetes control plane IPv4"
  value       = local.k8s_control_count > 0 ? incus_instance.vm_k8s_control[0].ipv4_address : null
}

output "k8s_control_ipv6" {
  description = "Kubernetes control plane IPv6"
  value       = local.k8s_control_count > 0 ? incus_instance.vm_k8s_control[0].ipv6_address : null
}

output "k8s_worker_ips" {
  description = "Kubernetes worker IPv4 addresses"
  value       = [for vm in incus_instance.vm_k8s_worker : vm.ipv4_address]
}

output "k8s_worker_ipv6s" {
  description = "Kubernetes worker IPv6 addresses"
  value       = [for vm in incus_instance.vm_k8s_worker : vm.ipv6_address]
}

output "k8s_nodes" {
  description = "All Kubernetes nodes with IPs"
  value = merge(
    local.k8s_control_count > 0 ? {
      "k8s-control" = {
        ipv4 = incus_instance.vm_k8s_control[0].ipv4_address
        ipv6 = incus_instance.vm_k8s_control[0].ipv6_address
        mac  = macaddress.vm_k8s_control_mac_vlan1[0].address
      }
    } : {},
    {
      for idx, vm in incus_instance.vm_k8s_worker : "k8s-worker${idx + 1}" => {
        ipv4 = vm.ipv4_address
        ipv6 = vm.ipv6_address
        mac  = macaddress.vm_k8s_worker_mac_vlan1[idx].address
      }
    }
  )
}
