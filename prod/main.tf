module "vms_cluster" {
  source = "../modules/vms_cluster"

  # Define VM names - customize as needed
  vm_names = [
    "worker03"
  ]

  # Map each VM to its OS type (centos, rhel, ubuntu)
  # VMs not listed here will use the default_os value
  vm_os_mapping = {
    "worker03" = "ubuntu"
  }

  # Override default OS paths if needed (optional)
  # os_images = {
  #   "centos" = "/path/to/custom/centos-10.qcow2"
  #   "rhel"   = "/path/to/custom/rhel10.1-base.qcow2"
  #   "ubuntu" = "/path/to/custom/ubuntu-base.qcow2"
  # }

  # Default OS for any VM not specified in vm_os_mapping
  default_os = "ubuntu"

  # Resource specifications for prod (higher resources)
  memory_mb = 4096        # 4GB RAM per VM
  vcpu      = 4           # 4 vCPUs per VM
  disk_size = 10 * 1024 * 1024 * 1024 #10737418240 # 10GB disk per VM

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

output "prod_vm_os_mapping" {
  description = "OS type for each VM"
  value       = module.vms_cluster.vm_os_mapping
}

output "prod_vm_image_paths" {
  description = "Golden image path used for each VM"
  value       = module.vms_cluster.vm_image_paths
}
