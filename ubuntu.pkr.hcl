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

source "virtualbox-iso" "ubuntu-ap-vbox" {

  # Boot Commands when Loading the ISO file with OVMF.fd file (Tianocore) / GrubV2
  # boot_command = [
  #   "<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait>",
  #   "e<wait>",
  #   "<down><down><down><end>",
  #   " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
  #   "<f10>"
  # ]
  boot_command = [
    "<esc><esc><enter><wait>", 
    "/install/vmlinuz noapic ", 
    "initrd=/install/initrd.gz ", 
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg", 
    "debian-installer=en_US auto locale=en_US kbd-chooser/method=us ", 
    "hostname=ubuntu-ap ", 
    "grub-installer/bootdev=/dev/sda<wait> ", 
    "fb=false debconf/frontend=noninteractive ", 
    "keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ", 
    "keyboard-configuration/variant=USA console-setup/ask_detect=false ", 
    "passwd/user-fullname=ap ", 
    "passwd/user-password=password ", 
    "passwd/user-password-again=password ", 
    "passwd/username=ap ", "-- <enter>"
  ]
  boot_wait = "5s"

  http_directory = "http"
  iso_url = "${var.iso_url}"
  iso_checksum = "${var.iso_checksum}"
  memory = 4096
  guest_os_type = "Ubuntu_64"
  guest_additions_mode    = "disable"
  hard_drive_interface    = "sata"

  ssh_password = "password"
  ssh_username = "ap"
  ssh_timeout = "20m"
  shutdown_command = "echo 'password' | sudo -S shutdown -P now"

  headless = var.headless
  format = "ova"
  disk_size = 40960
  cpus = 4

  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--audio", "none"], 
    ["modifyvm", "{{ .Name }}", "--usb", "off"], 
    ["modifyvm", "{{ .Name }}", "--vrde", "off"], 
    ["modifyvm", "{{ .Name }}", "--memory", "4096"], 
    ["modifyvm", "{{ .Name }}", "--cpus", "4"]
  ]
  
  vm_name = "ubuntu-ap-vbox"
}

build {
  sources = [ "source.virtualbox-iso.ubuntu-ap-vbox" ]
  provisioner "shell" {
    inline = [ "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done" ]
  }
}