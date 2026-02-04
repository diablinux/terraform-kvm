resource "libvirt_volume" "vm_disk" {
  for_each       = toset(var.vm_names)
  name           = "${each.key}-disk.qcow2"
  pool           = "default"
  
  target         = { format = { type = "qcow2" } }
  capacity       = var.disk_size

  create = {
    content = {
      url = "${var.base_image_path}"
    }
  }
}


resource "libvirt_domain" "machine" {
  type = "kvm"
  for_each = toset(var.vm_names)
  name   = each.key
  memory = var.memory_mb
  memory_unit = "MiB"
  vcpu   = var.vcpu
  
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
  
  devices = {
    disks = [ {
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
    } ]

    consoles = [ {
      type = "pty"
    } ]
    
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
      } ]
    }
  }
