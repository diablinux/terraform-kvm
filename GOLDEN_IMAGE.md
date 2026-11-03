# Ubuntu Golden Image from scratch

1. Download the cloud image
2. In lunux, install libguestfs-tools

   ```bash
   sudo apt install libguestfs-tools
   ```

3. Phase 1: Configuration Injection and Modification

    ```bash
    virt-customize -a resolute-server-cloudimg-amd64.qcow2 \
    --run-command 'useradd -m -s /bin/bash core' 
    ```

4. Phase 2: Phase 2: Cryptographic Injection and Service Configuration

    ```bash
    virt-customize -a resolute-server-cloudimg-amd64.qcow2 \
    --run-command "echo 'core ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-core-users" \
    --run-command 'chmod 0440 /etc/sudoers.d/90-core-users' \
    --run-command 'mkdir -p /home/core/.ssh' \
    --upload /home/acabrera/.ssh/id_rsa_core.pub:/home/core/.ssh/authorized_keys \
    --run-command 'chown -R core:core /home/core/.ssh' \
    --run-command 'chmod 0700 /home/core/.ssh' \
    --run-command 'chmod 0600 /home/core/.ssh/authorized_keys'
    ```

6. Install the qemu-guest-agent package

    ```bash
    virt-customize -a resolute-server-cloudimg-amd64.qcow2 --install qemu-guest-agent
    ```

7. Create an overlay with the golden image as backing image
   - In Ubuntu guests, expand the disk (See README.md)
   - Upgrade base packages
   - Install additional packages (e.g. openssh-server, vim, etc) 

8. Shutdown the VM
9.  Safe Merging via commit. If you instead wanted to push the changes made in the overlay dev-web-01-disk.qcow2 backward into the base file resolute-server-cloudimg-amd64.qcow2, you would use:

    ```bash
    qemu-img commit dev-web-01-disk.qcow2
    ```

10. Now our golden image has the latest changes from the overlay

11. Phase 3: Cryptographic and Systemic Sanitization

    ```bash
    virt-sysprep -a resolute-server-cloudimg-amd64.qcow2  \
    --operations defaults,-ssh-userdir,machine-id \
    --firstboot-command 'dpkg-reconfigure openssh-server'
    ```

12. Remove the dependency on the backing store (base image). To completely merge and flatten your overlay disk (e.g. dev-web-01-disk.qcow2) into a standalone image so it no longer depends on resolute-server-cloudimg-amd64.qcow2, use the unsafe rebase trick. This burns the backing data directly into the overlay file.
Run the following command while the VM is completely turned off:

    ```bash
    qemu-img rebase -b "" dev-web-01-disk.qcow2
    ```
1.  Before consolidation base <-- overlay. You would see the reference to the nacking file:

    ```bash
    qemu-img info --force-share dev-web-01-disk.qcow2
    image: dev-web-01-disk.qcow2
    file format: qcow2
    virtual size: 40 GiB (42949672960 bytes)
    disk size: 42.1 MiB
    cluster_size: 65536
    backing file: resolute-server-cloudimg-amd64.qcow2
    backing file format: qcow2
    Format specific information:
        compat: 1.1
        compression type: zlib
        lazy refcounts: false
        refcount bits: 16
        corrupt: false
        extended l2: false
    Child node '/file':
        filename: dev-web-01-disk.qcow2
        protocol type: file
        file length: 41.2 MiB (43188224 bytes)
        disk size: 42.1 MiB
        Format specific information:
            extent size hint: 1048576
    ```

2.  After the consolidation, no more references to the backing file:

    ```bash
    qemu-img info --force-share dev-web-01-disk.qcow2
    image: dev-web-01-disk.qcow2
    file format: qcow2
    virtual size: 40 GiB (42949672960 bytes)
    disk size: 2.8 GiB
    cluster_size: 65536
    Format specific information:
        compat: 1.1
        compression type: zlib
        lazy refcounts: false
        refcount bits: 16
        corrupt: false
        extended l2: false
    Child node '/file':
        filename: dev-web-01-disk.qcow2
        protocol type: file
        file length: 2.8 GiB (3011313664 bytes)
        disk size: 2.8 GiB
        Format specific information:
            extent size hint: 1048576
    ```
