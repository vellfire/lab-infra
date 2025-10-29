locals {
  k8s_control_count = var.k8s_enabled ? 1 : 0
  k8s_worker_count  = var.k8s_enabled ? var.k8s_worker_count : 0
}

/* Control Plane */

resource "macaddress" "vm_k8s_control_mac_eth0" {
  count  = local.k8s_control_count
  prefix = [16, 102, 106]
}

module "vm_k8s_control" {
  source = "./modules/incus-vm"
  count  = local.k8s_control_count

  name              = "k8ctrl${count.index + 1}"
  host              = element(var.k8s_control_hosts, count.index)
  cpus              = var.k8s_control_cpu
  memory            = var.k8s_control_memory
  os_disk_size      = var.k8s_control_os_size
  data_disk_size    = var.k8s_control_data_size
  vlan              = 114
  parent_nic        = var.k8s_network_parent[element(var.k8s_control_hosts, count.index)]
  mac_address       = macaddress.vm_k8s_control_mac_eth0[count.index].address
  image_fingerprint = module.ubuntu_stable_image.fingerprints[element(var.k8s_control_hosts, count.index)]

  cloud_init_user_data = templatefile(
    "${path.module}/templates/vms-k8s/user-data.tftpl",
    {
      name                = "k8ctrl${count.index + 1}",
      node_type           = "control",
      timezone            = var.vm_timezone,
      standard_username   = var.standard_username,
      standard_ssh_key    = var.standard_ssh_key,
      automation_username = var.automation_username,
      automation_uid      = var.automation_uid,
      automation_ssh_key  = var.automation_ssh_key
    }
  )

  cloud_init_network_config = templatefile(
    "${path.module}/templates/vms-k8s/network-config.tftpl",
    {
      name = "k8ctrl${count.index + 1}",
      mac  = macaddress.vm_k8s_control_mac_eth0[count.index].address
    }
  )
}

/* Worker nodes */

resource "macaddress" "vm_k8s_worker_mac_eth0" {
  count  = local.k8s_worker_count
  prefix = [16, 102, 106]
}

module "vm_k8s_worker" {
  source = "./modules/incus-vm"
  count  = local.k8s_worker_count

  name              = "k8wkr${count.index + 1}"
  host              = element(var.k8s_worker_hosts, count.index)
  cpus              = var.k8s_worker_cpu
  memory            = var.k8s_worker_memory
  os_disk_size      = var.k8s_worker_os_size
  data_disk_size    = var.k8s_worker_data_size
  vlan              = 114
  parent_nic        = var.k8s_network_parent[element(var.k8s_worker_hosts, count.index)]
  mac_address       = macaddress.vm_k8s_worker_mac_eth0[count.index].address
  image_fingerprint = module.ubuntu_stable_image.fingerprints[element(var.k8s_worker_hosts, count.index)]

  cloud_init_user_data = templatefile(
    "${path.module}/templates/vms-k8s/user-data.tftpl",
    {
      name                = "k8wkr${count.index + 1}",
      node_type           = "worker",
      timezone            = var.vm_timezone,
      standard_username   = var.standard_username,
      standard_ssh_key    = var.standard_ssh_key,
      automation_username = var.automation_username,
      automation_uid      = var.automation_uid,
      automation_ssh_key  = var.automation_ssh_key
    }
  )

  cloud_init_network_config = templatefile(
    "${path.module}/templates/vms-k8s/network-config.tftpl",
    {
      name = "k8wkr${count.index + 1}",  # Now matches the VM instance name
      mac  = macaddress.vm_k8s_worker_mac_eth0[count.index].address
    }
  )
}

output "k8s_nodes" {
  description = "k8s nodes"
  value = merge(
    {
      for idx in range(local.k8s_control_count) : "k8ctrl${idx + 1}" => {
        ipv4 = module.vm_k8s_control[idx].ipv4_address
        ipv6 = module.vm_k8s_control[idx].ipv6_address
        mac  = macaddress.vm_k8s_control_mac_eth0[idx].address
        host = element(var.k8s_control_hosts, idx)
        role = "control"
      }
    },
    {
      for idx in range(local.k8s_worker_count) : "k8wkr${idx + 1}" => {
        ipv4 = module.vm_k8s_worker[idx].ipv4_address
        ipv6 = module.vm_k8s_worker[idx].ipv6_address
        mac  = macaddress.vm_k8s_worker_mac_eth0[idx].address
        host = element(var.k8s_worker_hosts, idx)
        role = "worker"
      }
    }
  )
}
