# Rocky 9

## Purpose
The purpose of this Packer template is to create a virtual machine template for Rocky Linux 9.x on the Proxmox platform. Rocky Linux is an open-source enterprise operating system designed to be 100% bug-for-bug compatible with Red Hat Enterprise Linux. This template automates the creation of a virtual machine with the Rocky Linux 9.x operating system, pre-configured settings, and a customized kickstart file.

## Variables

- `name` (string): Specifies the name of the virtual machine template. The default value is set to "rocky-9".

- `proxmox_addr` (string): Specifies the address of the Proxmox server.

- `proxmox_node` (string): Specifies the Proxmox node where the virtual machine will be created.

- `proxmox_username` (string): Specifies the username for authenticating with the Proxmox server.

- `proxmox_password` (string): Specifies the password for authenticating with the Proxmox server.

- `proxmox_token` (string): Specifies the Proxmox API token. The default value is obtained from the `PACKER_PVE_TOKEN` environment variable.

- `vm_prefix` (string): Specifies a prefix for the virtual machine name.

- `iso_storage` (string): Specifies the storage pool where the ISO image will be mounted.
