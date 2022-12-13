variable "headless" {
  type = bool
  default = false
}

variable "iso_url" {
  type = string
  default = ""
}

variable "iso_checksum" {
  type = string
  default = ""
}

source "qemu" "ubuntu-ap" {

  # Boot Commands when Loading the ISO file with OVMF.fd file (Tianocore) / GrubV2
  boot_command = [
    "<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10>"
  ]
  boot_wait = "5s"

  http_directory = "http"
  iso_url = "${var.iso_url}"
  iso_checksum = "${var.iso_checksum}"
  memory = 4096

  ssh_password = "password"
  ssh_username = "ap"
  ssh_timeout = "20m"
  shutdown_command = "echo 'ubuntu-ap' | sudo -S shutdown -P now"

  headless = var.headless
  accelerator = "kvm"
  format = "qcow2"
  disk_size = "30G"
  cpus = 4

  qemuargs = [ # Depending on underlying machine the file may have different location
    ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"]
  ] 
  vm_name = "ubuntu-ap"
}

build {
  sources = [ "source.qemu.ubuntu-ap" ]
  provisioner "shell" {
    inline = [ "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done" ]
  }
}