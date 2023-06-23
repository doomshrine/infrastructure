# Ubuntu 22.04 LTS

## Purpose
The purpose of this Packer template is to create a virtual machine template for Ubuntu 22.04.x Linux on the Proxmox platform. It automates the creation of a virtual machine with Ubuntu 22.04.x, pre-configured settings, and cloud-init for automated provisioning.

## Variables

- `name` (string): Specifies the name of the virtual machine template. The default value is set to "ubuntu-22.04".

- `proxmox_addr` (string): Specifies the address of the Proxmox server.

- `proxmox_node` (string): Specifies the Proxmox node where the virtual machine will be created.

- `proxmox_username` (string): Specifies the username for authenticating with the Proxmox server.

- `proxmox_password` (string): Specifies the password for authenticating with the Proxmox server.

- `proxmox_token` (string): Specifies the Proxmox API token. The default value is obtained from the `PACKER_PVE_TOKEN` environment variable.

- `vm_prefix` (string): Specifies a prefix for the virtual machine name.

- `iso_storage` (string): Specifies the storage pool where the ISO image will be mounted.
