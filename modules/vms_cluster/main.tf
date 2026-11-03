locals {
  vm_size_profiles = {
    small = {
      memory_mb = 2048
      vcpu      = 2
      disk_size = 20 * 1024 * 1024 * 1024
    }
    medium = {
      memory_mb = 4096
      vcpu      = 4
      disk_size = 40 * 1024 * 1024 * 1024
    }
    large = {
      memory_mb = 8192
      vcpu      = 8
      disk_size = 60 * 1024 * 1024 * 1024
    }
  }

  # Get the image path for each VM based on its OS
  vm_image_paths = {
    for vm_name, vm in var.vm_map :
    vm_name => var.os_images[vm.vm_os]
  }
}

resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_map
  name     = "${each.key}-disk.qcow2"
  pool     = "pool"

  target   = { format = { type = "qcow2" } }
  capacity = local.vm_size_profiles[each.value.vm_size].disk_size

  backing_store = {
    path   = "resolute-server-cloudimg-amd64.img"
    format = {
      type = "qcow2"    
    }
  }

  # create = {
  #   content = {
  #     url = local.vm_image_paths[each.key]
  #   }
  # }
}


resource "libvirt_domain" "machine" {
  type        = "kvm"
  for_each    = var.vm_map
  name        = each.key
  memory      = local.vm_size_profiles[each.value.vm_size].memory_mb
  memory_unit = "MiB"
  vcpu        = local.vm_size_profiles[each.value.vm_size].vcpu

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
    mode  = "host-passthrough"
    check = "none"
  }

  devices = {
    # Modern syntax to create the QEMU Guest Agent channel interface
    channels = [
      {
        source = {
          unix = {}
        }
        target = {
          virt_io = {
            name = "org.qemu.guest_agent.0"
          }
        }
      }
    ]
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
