module "vms_cluster" {
  source = "../modules/vms_cluster"

  # Define VMs with their properties (OS and size) in a single map
  vm_props = {
    "ubuntu-lab-002" = {
      os   = "ubuntu"
      size = "medium"
    }
    "centos-lab-002" = {
      os   = "centos"
      size = "medium"
    }
    "rhel-lab-002" = {
      os   = "rhel"
      size = "medium"   # see modules/vms_cluster/variables.tf
    }
  }

  # Optional: Override default OS for VMs without explicit OS
  default_os = "ubuntu"

  # Optional: Override default VM size for VMs without explicit size
  default_vm_size = "medium"

  # Optional: Override default OS image paths
  # os_images = {
  #   "centos" = "/path/to/custom/centos-10.qcow2"
  #   "rhel"   = "/path/to/custom/rhel10.1-base.qcow2"
  #   "ubuntu" = "/path/to/custom/ubuntu-base.qcow2"
  # }

  # Optional: Override default VM size presets
  # vm_sizes = {
  #   "small" = {
  #     vcpu      = 1
  #     memory_mb = 1024
  #     disk_gb   = 10
  #   }
  #   "medium" = {
  #     vcpu      = 1
  #     memory_mb = 2048
  #     disk_gb   = 20
  #   }
  #   "large" = {
  #     vcpu      = 2
  #     memory_mb = 4096
  #     disk_gb   = 50
  #   }
  # }

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

output "prod_vm_size_mapping" {
  description = "Size type for each VM"
  value       = module.vms_cluster.vm_size_mapping
}

output "prod_vm_resources" {
  description = "Actual vCPU, memory (MB), and disk (GB) for each VM based on size"
  value       = module.vms_cluster.vm_resources
}

output "prod_vm_disk_sizes_bytes" {
  description = "Disk size in bytes for each VM (as used by libvirt)"
  value       = module.vms_cluster.vm_disk_sizes_bytes
}