// https://s3-us.vyos.io/rolling/current/vyos-rolling-latest.iso
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
  default = "vyos"
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
  vm_name      = "${var.vm_prefix}-${var.name}-template"
  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout  = "15m"

  // template
  template_name        = "${var.vm_prefix}-${var.name}-template"
  template_description = "${var.name}, generated on ${formatdate("YYYY MMM DD HH:mm:ss", timestamp())}"

  boot_wait = "10s"

  // we need to abuse the boot_command to install vyos
  boot_command = [
    "<enter><wait10><wait10><wait10><wait10><wait10><wait10>",                            // start booting process
    "vyos<enter><wait>",                                                                  // type default username
    "vyos<enter><wait>",                                                                  // type default password
    "install image<enter><wait>",                                                         // start installation process
    "<enter><wait>",                                                                      // asked if we want to install to disk, we do
    "<wait10><wait10><wait10>",                                                           // wait for probing the disk to finish
    "<enter><wait>",                                                                      // automatic partitioning
    "<enter><wait>",                                                                      // asked if we want to install to disk (disk-name), we do
    "Yes<enter><wait>",                                                                   // data loss warning, we know
    "<enter><wait10>",                                                                    // asked about partition size, agree to 100%
    "<enter><wait10>",                                                                    // asked about image name, agree to default
    "<enter><wait10>",                                                                    // asked about config name, agree to default
    "packer<enter><wait>",                                                                // enter new password for vyos user
    "packer<enter><wait>",                                                                // retyping it
    "<enter><wait>",                                                                      // GRUB partition, agree to default
    "<wait10><wait10>",                                                                   // wait for installation to finish
    "reboot<enter><wait>",                                                                // reboot
    "y<enter><wait>",                                                                     // asked if we want to reboot, we do
    "<wait10><wait10><wait10><wait10><wait10><wait10>",                                   // wait for reboot to finish
    "vyos<enter><wait>",                                                                  // type default username
    "packer<enter><wait>",                                                                // type new password
    "configure<enter><wait>",                                                             // enter config mode
    "set interfaces ethernet eth0 address dhcp<enter><wait>",                             // set eth0 to dhcp
    "set system login user packer full-name \"packer\"<enter><wait>",                     // create new user
    "set system login user packer authentication plaintext-password packer<enter><wait>", // set password for new user
    "set service ssh port 22<enter><wait>",                                               // enable ssh
    "commit<enter><wait10>",                                                              // commit changes
    "save<enter><wait10>",                                                                // save changes
    "exit<enter><wait5>",                                                                 // exit config mode
    "exit<enter><wait5>",                                                                 // exit shell
    "packer<enter><wait>",                                                                // login as new user
    "packer<enter><wait>",                                                                // type password
    "configure<enter><wait>",                                                             // enter config mode
    "delete system login user vyos<enter><wait>",                                         // delete default user
    "commit<enter><wait5>",                                                               // commit changes
    "save<enter><wait5>",                                                                 // save changes
    "exit<enter><wait5>",                                                                 // exit config mode
    "sudo reboot<enter><wait>"                                                            // shutdown
  ]

  // ISO
  unmount_iso      = true
  iso_url          = "https://s3-us.vyos.io/rolling/current/vyos-rolling-latest.iso"
  iso_checksum     = "none" // vyos does not provide checksums
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

  // network 1, WAN
  network_adapters {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  // network 2, LAN
  network_adapters {
    bridge   = "vmbr1"
    firewall = false
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
