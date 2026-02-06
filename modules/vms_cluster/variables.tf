variable "vm_names" {
  description = "List of VM names to create (e.g., vm01, vm02)"
  type        = list(string)
}

variable "vm_os_mapping" {
  description = "Map of VM names to their OS types (centos, rhel, ubuntu)"
  type        = map(string)
  default     = {}
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

variable "default_os" {
  description = "Default OS type if not specified for a VM (centos, rhel, ubuntu)"
  type        = string
  default     = "ubuntu"
}

variable "memory_mb" {
  description = "RAM in MB"
  type        = number
  default     = 2048
}

variable "vcpu" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
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

variable "disk_size" {
  description = "Disk size in bytes (10GB = 10737418240)"
  type        = number
  default     = 10737418240
}
