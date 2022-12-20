## Build

```
packer build -force -var-file x86_64.pkrvars.hcl ubuntu.pkr.hcl
```

## Start VM

```
qemu-system-x86_64 -enable-kvm -cpu host -smp cores=2 -machine type=pc,accel=kvm -net user,hostfwd=tcp::10022-:22 -net nic -bios /usr/share/OVMF/OVMF_CODE.fd -drive file=./output-ubuntu-ap/ubuntu-ap -m 2048
```
## With wifi dongle:

Find the values for hostbus=X,hostaddr=Y by running `lsusb`.

```
qemu-system-x86_64 -enable-kvm -cpu host -smp cores=2 -machine type=pc,accel=kvm -usb -device usb-host,hostbus=1,hostaddr=7 -net user,hostfwd=tcp::10022-:22 -net nic -bios /usr/share/OVMF/OVMF_CODE.fd -drive file=./output-ubuntu-ap/ubuntu-ap -m 2048
```

## Access via SSH

```
ssh admin@localhost -p 10022
```

## Generate encrypted password

For the main user in the user-data file. Run the following and enter the desired password when prompted.

```
openssl passwd -6 -salt xyz
```

sudo qemu-system-x86_64 -enable-kvm -cpu host -smp cores=2 -machine type=pc,accel=kvm -usb -device usb-host,hostbus=1,hostaddr=9 -net user,hostfwd=tcp::10022-:22 -net nic -monitor telnet:0.0.0.0:7101,server,nowait,nodelay -bios /usr/share/OVMF/OVMF_CODE.fd -drive file=./output-ubuntu-ap/ubuntu-ap -m 2048