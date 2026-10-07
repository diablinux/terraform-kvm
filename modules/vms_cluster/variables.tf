variable "vm_map" {
  description = "Map of VM names to their OS type and size"
  type = map(object({
    vm_os   = string
    vm_size = string
  }))

  validation {
    condition     = alltrue([for vm in values(var.vm_map) : contains(["small", "medium", "large"], vm.vm_size)])
    error_message = "Each vm_size must be one of: small, medium, or large."
  }
}

variable "os_images" {
  description = "Mapping of OS types to their golden image paths"
  type        = map(string)
  default = {
    "centos" = "/Users/diablinux/libvirt/images/centos-10.qcow2"
    "rhel"   = "/Users/diablinux/libvirt/images/rhel10.1-base.qcow2"
    "ubuntu" = "/Users/diablinux/libvirt/images/ubuntu-base.qcow2"
  }
}

variable "base_image_path" {
  description = "Path to the backing_store qcow2 image (deprecated - use os_images instead)"
  type        = string
  default     = ""
}

variable "network_name" {
  description = "Libvirt network to attach to"
  type        = string
  default     = "nm-bridge"
}
