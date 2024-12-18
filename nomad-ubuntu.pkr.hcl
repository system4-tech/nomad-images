packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "image_name" {
  default = "nomad-ubuntu"
}

variable "ssh_password" {
  default  = "ubuntu"
  sensitive = true
}

variable "ubuntu_version" {
  default = "24.04"
}

variable "nomad_version" {
  default = "1.9.3"
}

source "qemu" "ubuntu" {
  boot_wait        = "2s"
  iso_url          = "https://cloud-images.ubuntu.com/releases/${var.ubuntu_version}/release/ubuntu-${var.ubuntu_version}-server-cloudimg-amd64.img"
  iso_checksum     = "file:https://cloud-images.ubuntu.com/releases/${var.ubuntu_version}/release/SHA256SUMS"
  disk_image       = true
  output_directory = "${path.root}/output/${var.image_name}"
  format           = "qcow2"
  cd_files         = ["${path.root}/assets/user-data", "${path.root}/assets/meta-data"]
  cd_label         = "cidata"
  ssh_username     = "root"
  ssh_password     = var.ssh_password
  shutdown_command = "shutdown -P now"
  headless         = true
}

build {
  name    = "nomad-ubuntu"
  sources = ["source.qemu.ubuntu"]

  provisioner "file" {
    source      = "${path.root}/assets/nomad.hcl"
    destination = "/etc/nomad.d/nomad.hcl"
  }

  provisioner "file" {
    source      = "${path.root}/assets/nomad.service"
    destination = "/etc/systemd/system/nomad.service"
  }

  provisioner "shell" {
    script = "${path.root}/scripts/setup-boot.sh"
  }

  provisioner "shell" {
    script = "${path.root}/scripts/install-kernel.sh"
  }

  provisioner "shell" {
    inline = [
      "reboot"
    ]
    expect_disconnect = true
    pause_after       = "2m"
  }

  provisioner "shell" {
    script = "${path.root}/scripts/install-docker.sh"
  }

  provisioner "shell" {
    script          = "${path.root}/scripts/install-nomad.sh"
    environment_vars = ["NOMAD_VERSION=${var.nomad_version}"]
  }

  provisioner "shell" {
    script = "${path.root}/scripts/cleanup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl enable nomad",
      "sudo systemctl start nomad"
    ]
  }

  provisioner "shell" {
    inline = [
      "nomad version",
      "sudo systemctl status nomad"
    ]
  }

  provisioner "shell" {
    inline = [
      "docker --version",
      "sudo systemctl status docker"
    ]
  }
}
