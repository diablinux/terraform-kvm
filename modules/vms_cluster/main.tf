locals {
  # Determine OS for each VM: use specified OS or default
  vm_os = {
    for vm_name, props in var.vm_props :
    vm_name => coalesce(props.os, var.default_os)
  }

  # Get the image path for each VM based on its OS
  vm_image_paths = {
    for vm_name, os_type in local.vm_os :
    vm_name => lookup(var.os_images, os_type, var.os_images[var.default_os])
  }

  # Determine size for each VM: use specified size or default
  vm_size = {
    for vm_name, props in var.vm_props :
    vm_name => coalesce(props.size, var.default_vm_size)
  }

  # Resolve the actual vcpu, memory, and disk for each VM based on its size
  vm_resources = {
    for vm_name, size in local.vm_size :
    vm_name => lookup(var.vm_sizes, size, var.vm_sizes[var.default_vm_size])
  }

  # Convert disk_gb to bytes for libvirt (1 GB = 1073741824 bytes)
  vm_disk_sizes = {
    for vm_name, resources in local.vm_resources :
    vm_name => resources.disk_gb * 1073741824
  }
}



resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_props
  name     = "${each.key}-disk.qcow2"
  pool     = "default"

  target   = { format = { type = "qcow2" } }
  capacity = local.vm_disk_sizes[each.key]

  create = {
    content = {
      url = local.vm_image_paths[each.key]
    }
  }
}


resource "libvirt_domain" "machine" {
  type        = "kvm"
  for_each    = var.vm_props
  name        = each.key
  memory      = local.vm_resources[each.key].memory_mb
  memory_unit = "MiB"
  vcpu        = local.vm_resources[each.key].vcpu

  running   = true
  autostart = true

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
  }

  features = {
    acpi = true
  }

  cpu = {
    mode       = "host-passthrough"
    check      = "none"
  }

  devices = {
    disks = [{
      driver = {
        type = "qcow2"
      }
      source = {
        file = {
          file = libvirt_volume.vm_disk[each.key].id
        }
      }
      driver = { type = "qcow2" }
      target = { dev = "vda", bus = "virtio" }
    }]

    consoles = [{
      type = "pty"
    }]

    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          bridge = {
            bridge = "nm-bridge"
          }
        }
    }]
  }
}


