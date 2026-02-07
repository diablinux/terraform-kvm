variable "vm_props" {
  description = "Map of VM names to their properties (os and size)"
  type = map(object({
    os   = optional(string)
    size = optional(string)
  }))
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

variable "vm_sizes" {
  description = "Mapping of VM size names to their resource configurations (vCPU, memory, and disk)"
  type = map(object({
    vcpu    = number
    memory_mb = number
    disk_gb = number
  }))
  default = {
    "small" = {
      vcpu      = 1
      memory_mb = 1024
      disk_gb   = 10
    }
    "medium" = {
      vcpu      = 1
      memory_mb = 2048
      disk_gb   = 10
    }
    "large" = {
      vcpu      = 2
      memory_mb = 4096
      disk_gb   = 20
    }
  }
}

variable "default_vm_size" {
  description = "Default VM size if not specified for a VM (small, medium, large)"
  type        = string
  default     = "medium"
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

variable "default_disk_size_gb" {
  description = "Default disk size in GB if not specified in vm_size (deprecated - define in vm_sizes instead)"
  type        = number
  default     = 10
}
