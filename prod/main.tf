module "vms_cluster" {
  source = "../modules/vms_cluster"

  # Each VM is configured with its OS and resource size.

  vm_map = {}

  # vm_map = {
  #   "dev-web-01" = {
  #     vm_os   = "rhel"
  #     vm_size = "small"
  #   }
  # }

  # Override default OS path (optional)
  # os_images = {
  #   "centos" = "/path/to/custom/centos-10.qcow2"
  #   "rhel"   = "/path/to/custom/rhel10.1-base.qcow2"
  #   "ubuntu" = "/path/to/custom/ubuntu-base.qcow2"
  # }

  providers = {
    libvirt = libvirt
  }
}

output "prod_vm_ids" {
  description = "IDs of created production VMs"
  value       = module.vms_cluster.vm_ids
}

output "prod_vm_map" {
  description = "OS type and resource size for each VM"
  value       = module.vms_cluster.vm_map
}

output "prod_vm_image_paths" {
  description = "Golden image path used for each VM"
  value       = module.vms_cluster.vm_image_paths
}
