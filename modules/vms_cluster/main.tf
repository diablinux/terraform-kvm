locals {
  # Determine OS for each VM: use explicit mapping if provided, otherwise use default
  vm_os = {
    for vm_name in var.vm_names :
    vm_name => lookup(var.vm_os_mapping, vm_name, var.default_os)
  }

  # Get the image path for each VM based on its OS
  vm_image_paths = {
    for vm_name, os_type in local.vm_os :
    vm_name => lookup(var.os_images, os_type, var.os_images[var.default_os])
  }
}

resource "libvirt_volume" "vm_disk" {
  for_each = toset(var.vm_names)
  name     = "${each.key}-disk.qcow2"
  pool     = "default"

  target   = { format = { type = "qcow2" } }
  capacity = var.disk_size

  create = {
    content = {
      url = local.vm_image_paths[each.key]
    }
  }
}


resource "libvirt_domain" "machine" {
  type        = "kvm"
  for_each    = toset(var.vm_names)
  name        = each.key
  memory      = var.memory_mb
  memory_unit = "MiB"
  vcpu        = var.vcpu

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


