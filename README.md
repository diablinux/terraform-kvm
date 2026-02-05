# terraform-kvm

Automating KVM VM Creation with Terraform - A flexible infrastructure-as-code solution for provisioning and managing KVM virtual machines with support for multiple operating systems.

## Features

- **Multi-OS Support**: Provision VMs with CentOS, RHEL, or Ubuntu from golden images
- **Flexible VM Configuration**: Define VM names and assign OS types per VM
- **Scalable Infrastructure**: Easily create multiple VMs with consistent or custom configurations
- **Infrastructure as Code**: Define your entire VM cluster in Terraform configuration
- **Modular Design**: Reusable module structure for different environments (dev, prod, etc.)
- **Per-VM Customization**: Configure memory, vCPU, disk size, and OS independently for each VM

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

- **Local Values** (`locals`):
  - `vm_os`: Maps each VM name to its OS type (from `vm_os_mapping` or uses `default_os`)
  - `vm_image_paths`: Resolves the correct golden image path for each VM based on its OS

- **Resources**:
  - `libvirt_volume`: Creates VM disk images based on golden image templates
  - `libvirt_domain`: Creates and configures the actual KVM virtual machines

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
- `vm_names` (list): Names of VMs to create (e.g., `["web-01", "db-01"]`)

#### Optional but Important
- `vm_os_mapping` (map): Maps VM names to OS types
  - Example: `{ "web-01" = "ubuntu", "db-01" = "centos" }`
  - VMs without an entry use `default_os`

- `default_os` (string): Default OS for unmapped VMs (default: `"ubuntu"`)

#### VM Resources
- `memory_mb` (number): RAM per VM in MB (default: `2048`)
- `vcpu` (number): Virtual CPUs per VM (default: `2`)
- `disk_size` (number): Disk size in bytes (default: `10737418240` = 10GB)

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

  # Define VM names
  vm_names = [
    "ubuntu-lab-001",
    "centos-lab-001",
    "rhel-lab-001",
  ]

  # Map each VM to its OS type
  vm_os_mapping = {
    "ubuntu-lab-001" = "ubuntu"
    "centos-lab-001" = "centos"
    "rhel-lab-001"   = "rhel"
  }

  # Default OS for unmapped VMs
  default_os = "ubuntu"

  # Resource specifications
  memory_mb = 2048        # 2GB RAM per VM
  vcpu      = 2           # 2 vCPUs per VM
  disk_size = 10737418240 # 10GB disk per VM
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
- `prod_vm_os_mapping`: OS type for each VM
- `prod_vm_image_paths`: Golden image path used by each VM

## Example Scenarios

### Create Homogeneous Cluster (all Ubuntu)

```hcl
vm_names = ["app-01", "app-02", "app-03"]
default_os = "ubuntu"
# No vm_os_mapping needed - all use default
```

### Create Heterogeneous Cluster (mixed OS)

```hcl
vm_names = ["web-01", "web-02", "db-01", "cache-01"]
vm_os_mapping = {
  "web-01"   = "ubuntu"
  "web-02"   = "ubuntu"
  "db-01"    = "centos"
  "cache-01" = "rhel"
}
default_os = "ubuntu"
```

### Create VMs with Custom Resources

```hcl
module "vms_cluster" {
  source = "../modules/vms_cluster"
  
  vm_names = ["compute-01", "compute-02"]
  
  # High-resource VMs
  memory_mb = 8192        # 8GB RAM
  vcpu      = 4           # 4 vCPUs
  disk_size = 53687091200 # 50GB disk
}
```

## Outputs

The module provides the following outputs:

- `vm_names`: List of created VM names
- `vm_ids`: Libvirt internal IDs for each VM
- `vm_disks`: Disk file paths for each VM
- `vm_os_mapping`: OS type assigned to each VM
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
- Verify VM name is correctly spelled in `vm_os_mapping`
- Check `os_images` paths point to valid files
- Ensure `default_os` value is one of: `centos`, `rhel`, or `ubuntu`


### Resize / partition on ubuntu VM's

```bash
sudo parted -l
sudo growpart /dev/vda 1
sudo resize2fs /dev/vda1
df -h
```

## License

[Specify your license here]