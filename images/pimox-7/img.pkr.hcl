packer {
  required_plugins {
    ansible = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "default_hostname" {
  type    = string
  default = "pimox-ve"
}

variable "mount_path" {
  type    = string
  default = "/mnt/ubuntu-22.04.1"
}

variable "target_image_size" {
  type    = string
  default = "4G"
}

source "arm" "pimox-7" {
  file_urls             = ["https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-02-22/2023-02-21-raspios-bullseye-arm64-lite.img.xz"]
  file_checksum         = "883eb0006c8841b7950ef69a7bf55f73c2250ecc15e6bf507f39f0d82fa2ea0a"
  file_checksum_type    = "sha256"
  file_target_extension = "xz"
  file_unarchive_cmd    = ["xz", "-d", "$ARCHIVE_PATH"]

  image_path         = "2023-02-21-raspios-bullseye-arm64-lite.img"
  image_mount_path   = "/mnt/raspios-bullseye-arm64-lite"
  image_build_method = "reuse"
  image_type         = "dos"
  image_size         = "${var.target_image_size}"
  image_chroot_env = [
    "PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin",
  ]

  qemu_binary_source_path      = "/usr/bin/qemu-arm-static"
  qemu_binary_destination_path = "/usr/bin/qemu-arm-static"

  image_partitions {
    name         = "boot"
    type         = "c"
    start_sector = "8192"
    filesystem   = "vfat"
    size         = "256M"
    mountpoint   = "/boot"
  }

  image_partitions {
    name         = "root"
    type         = "83"
    start_sector = "532480"
    filesystem   = "ext4"
    size         = "0"
    mountpoint   = "/"
  }
}

build {
  sources = ["source.arm.pimox-7"]

  provisioner "shell" {
    inline = [
      // setup networking
      "rm -f /etc/resolv.conf",
      "echo 'nameserver 1.1.1.1' > /etc/resolv.conf",
      "echo 'nameserver 8.8.8.8' >> /etc/resolv.conf",
    ]
  }

  provisioner "ansible" {
    playbook_file = "./ansible/playbooks/00-prechcecks.yml"
    user          = "root"
    ansible_env_vars = [
      "PYTHONUNBUFFERED=1",
    ]

    extra_arguments = [
      "--connection=chroot",
      "--extra-vars", "ansible_host=${var.mount_path}",
      "--extra-vars", "hostname=${var.default_hostname}",
    ]
  }

  provisioner "ansible" {
    playbook_file = "./ansible/playbooks/10-pimox.yml"
    user          = "root"
    ansible_env_vars = [
      "PYTHONUNBUFFERED=1",
    ]

    extra_arguments = [
      "--connection=chroot",
      "--extra-vars", "ansible_host=${var.mount_path}",
      "--extra-vars", "distro=jammy",
      "--extra-vars", "release=jammy",
    ]
  }
}
