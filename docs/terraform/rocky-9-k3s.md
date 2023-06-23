# Rocky 9 (K3s)

## Purpose
This Terraform file is used to provision multiple virtual machines (VMs) with Rocky Linux 9 operating system on a Proxmox hypervisor, specifically for running a Kubernetes cluster using K3s.

## Variables

- `proxmox_addr` (string): The address of the Proxmox server.

- `proxmox_node` (string): The name of the Proxmox node where the VMs will be created.

- `proxmox_username` (string): The username used to authenticate with the Proxmox server.

- `proxmox_password` (string): The password used to authenticate with the Proxmox server.

- `storage` (string): The storage identifier where the VMs will be stored.

- `os_minor_version` (number, default: 2): The minor version of Rocky Linux 9 to be used for the VMs.

- `replica_count` (number): Number of VMs to create.

- `core_count` (number, default: 4): Number of cores per VM.

- `memory_gib` (number, default: 8): Memory per VM in GiB.

- `disk_size_gib` (number, default: 120): Disk size per VM in GiB.
