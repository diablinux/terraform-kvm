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
  value       = {
    for name, disk in libvirt_volume.vm_disk : name => disk.path
  }
}