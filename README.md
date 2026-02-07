# terraform-kvm

Automating KVM VM Creation with Terraform - A flexible infrastructure-as-code solution for provisioning and managing KVM virtual machines with support for multiple operating systems.

## Features

- **Multi-OS Support**: Provision VMs with CentOS, RHEL, or Ubuntu from golden images
- **Flexible VM Sizing**: Choose from predefined sizes (small, medium, large) or custom configurations
- **Unified VM Configuration**: Define VM name, OS, and size all in one consolidated property map
- **Scalable Infrastructure**: Easily create multiple VMs with consistent or custom configurations
- **Infrastructure as Code**: Define your entire VM cluster in Terraform configuration
- **Modular Design**: Reusable module structure for different environments (dev, prod, etc.)
- **Per-VM Customization**: Configure OS and resources independently for each VM

## Project Structure

```
terraform-kvm/
├── README.md                           # This file
├── modules/
│   └── vms_cluster/                   # Main module for VM provisioning
│       ├── main.tf                    # Resource definitions (volumes, domains)
│       ├── variables.tf               # Input variables
│       ├── outputs.tf                 # Module outputs
│       └── versions.tf                # Provider requirements
└── prod/
    ├── main.tf                        # Production environment configuration
    └── terraform.tf                   # Provider configuration
```

## How It Works

### 1. Module (`modules/vms_cluster/`)

The module handles the core VM provisioning logic:

- **Input Variable** (`vm_props`):
  - Consolidated map where each VM defines its name, OS type, and size
  - Example: `{ "web-01" = { os = "ubuntu", size = "medium" } }`

- **Local Values** (`locals`):
  - `vm_os`: Determines OS for each VM (from `vm_props.os` or uses `default_os`)
  - `vm_image_paths`: Resolves the correct golden image path for each VM based on its OS
  - `vm_size`: Determines size for each VM (from `vm_props.size` or uses `default_vm_size`)
  - `vm_resources`: Resolves actual vCPU, memory, and disk for each VM based on its size
  - `vm_disk_sizes`: Converts disk_gb to bytes for libvirt volume capacity

- **Resources**:
  - `libvirt_volume`: Creates VM disk images based on golden image templates
  - `libvirt_domain`: Creates and configures the actual KVM virtual machines with appropriate resources

### 2. Golden Images

The solution uses three pre-built golden images located at `/Users/diablinux/libvirt/images/`:

| OS | Image Path | Size |
|----|-----------|------|
| CentOS | `centos-10.qcow2` | Pre-configured |
| RHEL | `rhel10.1-base.qcow2` | Pre-configured |
| Ubuntu | `ubuntu-base.qcow2` | Pre-configured |

### 3. Configuration Variables

Key variables allow customization:

#### Required
- `vm_props` (map): Consolidated VM properties map with structure:
  ```hcl
  vm_props = {
    "vm-name" = {
      os   = optional(string)   # centos, rhel, ubuntu
      size = optional(string)   # small, medium, large
    }
  }
  ```
  - `os` and `size` properties are optional; missing values use defaults
  - Example: `{ "web-01" = { os = "ubuntu", size = "medium" } }`

#### VM Size Presets (Default)
- **small**: 1 vCPU, 1GB memory, 10GB disk
- **medium**: 1 vCPU, 2GB memory, 20GB disk
- **large**: 2 vCPU, 4GB memory, 50GB disk

#### Optional
- `default_os` (string): Default OS for VMs without explicit OS (default: `"ubuntu"`)
- `default_vm_size` (string): Default size for VMs without explicit size (default: `"medium"`)
- `vm_sizes` (map): Override or extend size presets with custom configurations
  - Each size must include `vcpu`, `memory_mb`, and `disk_gb` properties
- `os_images` (map): Override golden image paths (default: points to `/Users/diablinux/libvirt/images/`)
- `network_name` (string): Libvirt network to attach to (default: `"nm-bridge"`)

## Usage

### 1. Configure Your VMs

Edit `prod/main.tf` to define your VM cluster using `vm_props`:

```hcl
module "vms_cluster" {
  source = "../modules/vms_cluster"

  # Define VMs with their properties (OS and size) in a single map
  vm_props = {
    "ubuntu-web-01" = {
      os   = "ubuntu"
      size = "medium"  # 1 vCPU, 2GB memory, 20GB disk
    }
    "centos-db-01" = {
      os   = "centos"
      size = "large"   # 2 vCPU, 4GB memory, 50GB disk
    }
    "rhel-cache-01" = {
      os   = "rhel"
      size = "small"   # 1 vCPU, 1GB memory, 10GB disk
    }
  }

  # Optional: Set defaults for properties not explicitly specified
  default_os      = "ubuntu"
  default_vm_size = "medium"
}
```

### 2. Initialize Terraform

```bash
cd prod
terraform init
```

### 3. Plan Your Deployment

```bash
terraform plan
```

### 4. Apply Configuration

```bash
terraform apply
```

### 5. Verify Outputs

After applying, view your VM details:

```bash
terraform output
```

Expected outputs:
- `prod_vm_names`: List of created VM names
- `prod_vm_ids`: Libvirt VM IDs
- `prod_vm_os_mapping`: OS type assigned to each VM
- `prod_vm_image_paths`: Golden image path used by each VM
- `prod_vm_size_mapping`: Size type assigned to each VM
- `prod_vm_resources`: Actual vCPU and memory configuration for each VM

## Example Scenarios

### Create Homogeneous Cluster (all Ubuntu, same size)

```hcl
vm_props = {
  "app-01" = { os = "ubuntu", size = "medium" }
  "app-02" = { os = "ubuntu", size = "medium" }
  "app-03" = { os = "ubuntu", size = "medium" }
}
```

### Create Heterogeneous Cluster (mixed OS and sizes)

```hcl
vm_props = {
  "web-01"   = { os = "ubuntu", size = "small" }
  "web-02"   = { os = "ubuntu", size = "small" }
  "db-01"    = { os = "centos", size = "large" }
  "cache-01" = { os = "rhel",   size = "medium" }
}
```

### Use Defaults for Partial Configuration

```hcl
vm_props = {
  "vm-01" = { size = "small" }        # Uses default_os (ubuntu)
  "vm-02" = { os = "centos" }         # Uses default_vm_size (medium)
  "vm-03" = {}                        # Uses both defaults
}

default_os      = "ubuntu"
default_vm_size = "medium"
```

### Create VMs with Custom Size Presets

```hcl
vm_props = {
  "compute-01" = { os = "ubuntu", size = "xlarge" }
  "compute-02" = { os = "ubuntu", size = "xlarge" }
}

# Define custom size presets (disk_gb is in gigabytes, converted to bytes for libvirt)
vm_sizes = {
  "small" = {
    vcpu      = 1
    memory_mb = 1024
    disk_gb   = 10
  }
  "medium" = {
    vcpu      = 1
    memory_mb = 2048
    disk_gb   = 20
  }
  "large" = {
    vcpu      = 2
    memory_mb = 4096
    disk_gb   = 50
  }
  "xlarge" = {
    vcpu      = 4
    memory_mb = 8192
    disk_gb   = 100
  }
}
```

## Outputs

The module provides the following outputs:

- `vm_names`: List of created VM names
- `vm_ids`: Libvirt internal IDs for each VM
- `vm_disks`: Disk file paths for each VM
- `vm_os_mapping`: OS type assigned to each VM
- `vm_image_paths`: Golden image path used for each VM
- `vm_size_mapping`: Size type assigned to each VM
- `vm_resources`: Actual vCPU, memory (MB), and disk (GB) configuration for each VM
- `vm_disk_sizes_bytes`: Disk size in bytes for each VM (as used by libvirt)

## Prerequisites

- Terraform >= 1.0
- Libvirt provider configured (`dmacvicar/libvirt` v0.9.2+)
- KVM/QEMU hypervisor with libvirt daemon running
- Pre-configured libvirt default storage pool
- Golden image files at `/Users/diablinux/libvirt/images/`

## Provider Configuration

The provider is configured in `prod/terraform.tf`. Update the URI as needed:

```hcl
provider "libvirt" {
  uri = "qemu+sshcmd://acabrera@server.local/session"
}
```

For local connection, use: `uri = "qemu:///system"`

## Network Configuration

All VMs connect to the `nm-bridge` bridge network. Ensure this network exists in libvirt:

```bash
virsh net-list
virsh net-start nm-bridge
```

## Troubleshooting

### VMs don't start
- Verify golden images exist at the configured paths
- Check libvirt storage pool permissions
- Ensure `nm-bridge` network is active

### Terraform plan fails
- Run `terraform init` in the prod directory
- Verify provider connectivity to libvirt daemon
- Check Terraform state file for conflicts

### OS or size not recognized
- Verify VM name is correctly spelled in `vm_props`
- Check `os` property is one of: `centos`, `rhel`, `ubuntu`
- Check `size` property is one of: `small`, `medium`, `large` (or custom if defined)
- Verify `os_images` and `vm_sizes` paths/definitions are valid
- Ensure `default_os` and `default_vm_size` values are valid


### Resize / partition on ubuntu VM's

```bash
sudo parted -l
sudo growpart /dev/vda 1
sudo resize2fs /dev/vda1
df -h
```

## License

[Specify your license here]