variable "vm_names" {
  description = "List of VM names to create (e.g., vm01, vm02)"
  type        = list(string)
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
  description = "Path to the backing_store qcow2 image"
  type        = string
  default = "/Users/diablinux/source_code/k8s_clusters/prod/ubuntu-base.qcow2"
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
