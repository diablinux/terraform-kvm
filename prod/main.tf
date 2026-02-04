module "vms_cluster" {
  source = "../modules/vms_cluster"

  # vm_names = [ "ubuntu-lab1" ]

  vm_names = [
    "ubuntu-1",
    "ubuntu-2",
    "ubuntu-3",
  ]

  # Resource specifications for prod (higher resources)
  memory_mb = 2048        # 2GB RAM per VM
  vcpu      = 2           # 2 vCPUs per VM
  disk_size = 10737418240 # 10GB disk per VM


  providers = {
    libvirt = libvirt
  }
}

# Outputs for accessing the cluster
output "prod_vm_names" {
  description = "Names of created production VMs"
  value       = module.vms_cluster.vm_names
}

output "prod_vm_ids" {
  description = "IDs of created production VMs"
  value       = module.vms_cluster.vm_ids
}