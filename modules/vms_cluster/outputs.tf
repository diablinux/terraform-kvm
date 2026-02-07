# Module outputs

output "vm_names" {
  description = "List of created VM names"
  value       = keys(libvirt_domain.machine)
}

output "vm_ids" {
  description = "List of created VM IDs"
  value       = [for vm in libvirt_domain.machine : vm.id]
}

output "vm_disks" {
  description = "Disk information for all VMs"
  value = {
    for name, disk in libvirt_volume.vm_disk : name => disk.path
  }
}

output "vm_os_mapping" {
  description = "OS type assigned to each VM"
  value       = local.vm_os
}

output "vm_image_paths" {
  description = "Golden image path used for each VM"
  value       = local.vm_image_paths
}

output "vm_size_mapping" {
  description = "Size type assigned to each VM"
  value       = local.vm_size
}

output "vm_resources" {
  description = "Actual vCPU, memory, and disk for each VM based on size"
  value       = local.vm_resources
}

output "vm_disk_sizes_bytes" {
  description = "Disk size in bytes for each VM"
  value       = local.vm_disk_sizes
}