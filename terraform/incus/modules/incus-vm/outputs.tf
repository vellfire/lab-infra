output "instance" {
  description = "VM instance resource"
  value       = incus_instance.vm
}

output "ipv4_address" {
  description = "VM IPv4 address"
  value       = incus_instance.vm.ipv4_address
}

output "ipv6_address" {
  description = "VM IPv6 address"
  value       = incus_instance.vm.ipv6_address
}

output "mac_address" {
  description = "VM MAC address"
  value       = local.mac_address
}

output "name" {
  description = "VM name"
  value       = incus_instance.vm.name
}

output "status" {
  description = "VM status"
  value       = incus_instance.vm.status
}
