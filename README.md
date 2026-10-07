# terraform-kvm

Automating KVM VM Creation with Terraform - A flexible infrastructure-as-code solution for provisioning and managing KVM virtual machines with support for multiple operating systems.

## Features

- **Multi-OS Support**: Provision VMs with CentOS, RHEL, or Ubuntu from golden images
- **Flexible VM Configuration**: Define each VM's name, OS, and resource size
- **Scalable Infrastructure**: Easily create multiple VMs with consistent or custom configurations
- **Infrastructure as Code**: Define your entire VM cluster in Terraform configuration
- **Modular Design**: Reusable module structure for different environments (dev, prod, etc.)
- **Per-VM Customization**: Configure OS and choose a small, medium, or large resource profile for each VM

## Project Structure

```file
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

- **Local Values** (`locals`):
  - `vm_image_paths`: Resolves the correct golden image path for each VM based on its `vm_os`
  - `vm_size_profiles`: Resolves memory, vCPU, and disk capacity from the selected `vm_size`
- **VM Definition**: Each `vm_map` key is a VM name and its value contains the VM's OS and size.

- **Resources**:
  - `libvirt_volume`: Creates VM disk images based on golden image templates
  - `libvirt_domain`: Creates and configures the actual KVM virtual machines

### 2. Golden Images

The solution uses three pre-built golden images located at `/Users/diablinux/libvirt/images/`:

| OS | Image Path | Size |
| ---- | ----------- | ------ |
| CentOS | `centos-10.qcow2` | Pre-configured |
| RHEL | `rhel10.1-base.qcow2` | Pre-configured |
| Ubuntu | `ubuntu-base.qcow2` | Pre-configured |

### 3. Configuration Variables

Key variables allow customization:

#### Required

- `vm_map` (map): Defines each VM name, OS, and size. Every VM must have an entry.

#### VM Size Profiles

Each VM's `vm_size` must be `small`, `medium`, or `large`. The initial profile values are:

| Size | Memory | vCPU | Disk |
| ---- | ------ | ---- | ---- |
| `small` | 2 GiB | 2 | 10 GiB |
| `medium` | 4 GiB | 4 | 20 GiB |
| `large` | 8 GiB | 8 | 50 GiB |

#### Advanced

- `os_images` (map): Override golden image paths if needed
  - Keys: `"centos"`, `"rhel"`, `"ubuntu"`
  - Default points to `/Users/diablinux/libvirt/images/`

## Usage

### 1. Configure Your VMs

Edit `prod/main.tf` to define your VM cluster:

```hcl
module "vms_cluster" {
  source = "../modules/vms_cluster"

  # Each key is a VM name; set its OS and size in the object.
  vm_map = {
    "ubuntu-lab-001" = {
      vm_os   = "ubuntu"
      vm_size = "small"
    }
    "centos-lab-001" = {
      vm_os   = "centos"
      vm_size = "medium"
    }
    "rhel-lab-001" = {
      vm_os   = "rhel"
      vm_size = "large"
    }
  }
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
- `prod_vm_map`: OS type and size for each VM
- `prod_vm_image_paths`: Golden image path used by each VM

## Example Scenarios

### Create Homogeneous Cluster (all Ubuntu)

```hcl
vm_map = {
  "app-01" = { vm_os = "ubuntu", vm_size = "small" }
  "app-02" = { vm_os = "ubuntu", vm_size = "small" }
  "app-03" = { vm_os = "ubuntu", vm_size = "small" }
}
```

### Create Heterogeneous Cluster (mixed OS)

```hcl
vm_map = {
  "web-01"   = { vm_os = "ubuntu", vm_size = "small" }
  "web-02"   = { vm_os = "ubuntu", vm_size = "small" }
  "db-01"    = { vm_os = "centos", vm_size = "medium" }
  "cache-01" = { vm_os = "rhel", vm_size = "large" }
}
```

### Create VMs with Custom Resources

```hcl
module "vms_cluster" {
  source = "../modules/vms_cluster"
  
  vm_map = {
    "compute-01" = { vm_os = "ubuntu", vm_size = "large" }
    "compute-02" = { vm_os = "ubuntu", vm_size = "large" }
  }
}
```

## Outputs

The module provides the following outputs:

- `vm_names`: List of created VM names
- `vm_ids`: Libvirt internal IDs for each VM
- `vm_disks`: Disk file paths for each VM
- `vm_map`: OS type and size assigned to each VM
- `vm_image_paths`: Golden image path used for each VM

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

### OS mismatch error

- Verify VM name is correctly spelled in `vm_map`
- Check `os_images` paths point to valid files
- Ensure each `vm_os` value in `vm_map` has a matching key in `os_images`
- Ensure each `vm_size` is `small`, `medium`, or `large`

### Resize / partition on ubuntu VM's

```bash
sudo parted -l
sudo growpart /dev/vda 1
sudo resize2fs /dev/vda1
df -h
```

## License

[Specify your license here]
