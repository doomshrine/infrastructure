# Quickstart

## Pre-requisites

To run the following examples, you will need to have the following installed:

- [just](https://github.com/casey/just)
- [packer](https://www.packer.io/)
- [python3 (>=3.9)](https://www.python.org/downloads/)
- [pip](https://pip.pypa.io/en/stable/getting-started/)

You will also need to have the Proxmox VE installed on a VM or bare metal server.

## Configuration

Run `just config` to generate configuration files. This will prompt you for the following:

- Proxmox Address - The IP address of your Proxmox VE server. No protocol, port, or trailing slash.
- Proxmox Node - The name of the Proxmox node to use for building images.
- Proxmox User - The username to use for authenticating with the Proxmox API.
- Proxmox Password - The password to use for authenticating with the Proxmox API.
- Storage Pool - The name of the Proxmox storage pool to use for building images.
- Prefix - The prefix to use for the names of the VM templates created by Packer.

The new configuration files will be saved to:

- `~/.config/packer/variables.pkrvars.hcl` - Packer variables file.
- `~/.config/terraform/terraform.tfvars` - Terraform variables file.

You can edit these files directly if you need to change any of the values.

## Building templates

Run `just templates` to build the following templates:

- `rocky-9` - Rocky 9.x minimal, the minor version is picked up automatically from the Release page.
- `ubuntu-22.04` - Ubuntu 22.04 LTS Server - the patch version is picked up automatically from the Release page.
- `vyos` - VyOS nightly build. Installation is quite sketchy, but it works. Always uses the latest nightly build.

### Deploying K3s HA Cluster with Cilium CNI and Kured

1. Run `just k3s`. It will build the template, start the VMs, initialize them and finally install K3s.
    - You will be asked for some inputs:
        1. When bringing up infrastructure, you need to pass number of nodes. Answer `5`, so there will be no modifications to other scripts needed.
        2. You will need inventory file. This can be generated. Just answer `Y` when asked for generating it, and provide all necessary information.
        3. Finally you will be asked which host group should be used. If you generated new inventory file, then type `generated`. Otherwise use the file you created manually.
2. Run `just k3s_cilium` to install Cilium CNI and Hubble.
3. Run `just k3s_kured "<SHOUTRR URL>"` (providing valid Shoutrrr notification URL), so the Kured will be installed.
