terraform {
  required_version = ">= 1.4.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

variable "proxmox_addr" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_username" {
  type = string
}

variable "proxmox_password" {
  type = string
}

variable "storage" {
  type = string
}

variable "os_minor_version" {
  type    = number
  default = 2
}

variable "replica_count" {
  # Number of VMs to create
  type = number
}

variable "core_count" {
  # Number of cores per VM
  type    = number
  default = 4
}

variable "memory_gib" {
  # Memory per VM in GiB
  type    = number
  default = 8
}

variable "disk_size_gib" {
  # Disk size per VM in GiB
  type    = number
  default = 120
}

provider "proxmox" {
  pm_api_url      = "https://${var.proxmox_addr}:8006/api2/json"
  pm_user         = var.proxmox_username
  pm_password     = var.proxmox_password
  pm_tls_insecure = true

  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

resource "proxmox_vm_qemu" "rocky-9" {
  count = var.replica_count
  name  = "rocky-9.${var.os_minor_version}-k3s-tf.${count.index + 1}"

  target_node = var.proxmox_node
  clone       = "hl-rocky-9.${var.os_minor_version}-template"

  cores    = var.core_count
  memory   = var.memory_gib * 1024
  agent    = 1
  os_type  = "cloud-init"
  sockets  = 1
  cpu      = "host"
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot    = 0
    size    = "${var.disk_size_gib}G"
    type    = "scsi"
    storage = var.storage
  }

  network {
    model  = "virtio"
    bridge = "vmbr1"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
