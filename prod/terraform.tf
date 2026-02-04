terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.2"
    }
  }
}

provider "libvirt" {
  # Connect to the local system (qemu:///system)
  uri = "qemu+sshcmd://acabrera@server.local/session"
}