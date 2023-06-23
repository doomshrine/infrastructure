packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "name" {
  type    = string
  default = "rocky-9"
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

variable proxmox_token {
  type    = string
  default = env("PACKER_PVE_TOKEN")
}

variable vm_prefix {
  type = string
}

variable iso_storage {
  type = string
}

source "proxmox-iso" "pve" {
  // proxmox config
  insecure_skip_tls_verify = true
  node                     = "${var.proxmox_node}"
  os                       = "l26"
  proxmox_url              = "https://${var.proxmox_addr}:8006/api2/json"
  username                 = "${var.proxmox_username}"
  password                 = "${var.proxmox_password}"

  // vm
  vm_name      = "${var.vm_prefix}-${var.name}.${file("./generated/minor.txt")}-template"
  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout  = "15m"

  // template
  template_name        = "${var.vm_prefix}-${var.name}.${file("./generated/minor.txt")}-template"
  template_description = "${var.name}, generated on ${formatdate("YYYY MMM DD HH:mm:ss", timestamp())}"

  // kickstart
  http_directory = "generated/"
  boot_wait      = "10s"
  boot_command   = ["<tab> text ip=dhcp inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"]

  // ISO
  unmount_iso      = true
  iso_url          = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.${file("./generated/minor.txt")}-x86_64-minimal.iso"
  iso_checksum     = "${file("./generated/checksum.txt")}"
  iso_storage_pool = "${var.iso_storage}"

  // CPU and memory
  cpu_type = "host"
  cores    = "2"
  memory   = "2048"

  // disk
  scsi_controller = "virtio-scsi-pci"
  disks {
    disk_size    = "40G"
    storage_pool = "base-pool"
    type         = "scsi"
  }

  // network
  network_adapters {
    bridge   = "vmbr0"
    firewall = true
    model    = "virtio"
  }

  // graphics
  vga {
    type = "std"
  }
}

build {
  sources = ["source.proxmox-iso.pve"]
}
