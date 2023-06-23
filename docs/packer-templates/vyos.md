# VyOS

## Purpose
The purpose of this Packer template is to create a virtual machine template for VyOS Rolling Release on the Proxmox platform. It automates the creation of a virtual machine with VyOS Rolling Release, pre-configured settings, and an installation process using the VyOS command-line interface.

## Variables

- `name` (string): Specifies the name of the virtual machine template. The default value is set to "vyos".

- `proxmox_addr` (string): Specifies the address of the Proxmox server.

- `proxmox_node` (string): Specifies the Proxmox node where the virtual machine will be created.

- `proxmox_username` (string): Specifies the username for authenticating with the Proxmox server.

- `proxmox_password` (string): Specifies the password for authenticating with the Proxmox server.

- `proxmox_token` (string): Specifies the Proxmox API token. The default value is obtained from the PACKER_PVE_TOKEN environment variable.

- `vm_prefix` (string): Specifies a prefix for the virtual machine name.

- `iso_storage` (string): Specifies the storage pool where the ISO image will be mounted.
