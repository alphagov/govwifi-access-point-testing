# Govwifi Access Point Testing

This document describes how to set up a Raspberry Pi to act as an access point to enable testing FreeRADIUS configurations with real client devices.

### How to Use

Follow the instructions for setting up a Raspberry Pi with the Raspberry Pi OS. You can then continue with the step-by-step instructions to configure the access point or simply run the following command in the terminal:

```
fix this.
```

### Other branches

The other branches in this repo are work in progress attempts to configure a software-only access point using Docker, QEMU and Virtualbox. They will either be completed, including the addition of documentation, or removed as the project progresses.

### Compatibility

The following has been tested on a Raspberry Pi 4, which has built in Wifi as well as an ethernet port. It did not work, when tested, on an original model Raspberry Pi, without ethernet port, using any of several USB/ethernet adapters.

Download the Raspberry Pi OS from [here](https://www.raspberrypi.org/software/operating-systems/)

Choose the 'Lite' image, without desktop environment or other tools.

### Other devices

This method of setting up an access point should work with any Debian-based machine with both a wifi adapter and ethernet adapter.

Either follow the instructions below from 'Setting up the access point' onwards or run the setup script on an existing Debian etc machine. Some small changes to the script/instructions will be needed to correctly set the names of the network adapters.

Please note that the wifi/network configuration the script/instructions implement is probably highly undesirable for any machine which isn't being used as a dedicated access point.

## Setting up the Raspberry Pi

### Flashing the OS using a GUI

The Raspberry Pi foundation provides [a tool for flashing the OS](https://www.raspberrypi.org/software/) and [a short video](https://www.youtube.com/watch?v=ntaXWS8Lk34&feature=youtu.be) explaining but if you prefer the terminal, follow the steps below.

If your card doesn't work whe you try to boot from it then follow the steps under 'Re-using an SD card' below.

When you have flashed the card create an empty file called 'ssh' in the root of the boot partition, either through a desktop file manager or using the instructions below under 'Enabling ssh'.

### Flashing the OS from the terminal

Extract the .img file from the zip and enter the directory containing it in the terminal.

Enter `sudo blkid` to see a list of attached disks. Attach/insert an SD card to your machine and enter `sudo blkid` to see which device
(whichever has newly appeared on the list) has been allocated to the SD card, e.g. /dev/sdf.

#### Re-using an SD card

dd doesn't always behave as expeced when using an SD card with multiple partitions, which any previously-used on a Raspberry Pi will have, so it's best to clear the card in advance.

This can easily be done using a tool like Gparted. The MacOS Disk Utility (or at least the recent versions) and several other GUI tools do not always produce something usable when clearing multi-parition SD cards.

A multi-partition SD card can be cleared on the command line as follows:

Assuming your SD card is /dev/sdf

```
sudo parted /dev/sdf
```

Then at the parted command prompt:

```
(parted) mklabel gpt
```

This may not work on MacOS, in which case try:


```
(parted) mklabel mac
```

Then:

```
(parted) quit
```

Enter:

```
sudo dd if=./2021-05-07-raspios-buster-armhf-lite.img of=/dev/sdf bs=4M
```

...where '2021-05-07-raspios-buster-armhf-lite.img' is the name of the .img file, which may be different and /dev/sdf is the device
identified above.

If you're using MacOS and it complains about the bs=4M option, try:

```
sudo dd if=./2021-05-07-raspios-buster-armhf-lite.img of=/dev/sdf bs=4m
```

#### Creating a user and enabling ssh

When dd has finished running the newly flashed SD card should have it's boot partition mounted automatically. Assuming this is at /media/username/boot, run the following (replacing 'username' with your username):

```
touch /media/username/boot/ssh
```

Copy the `userconf` file into the boot partition. This will automatically create a user called 'ap' with the password 'password'.

#### Raspberry Pi hardware setup

This will depend on which version of the Raspberry Pi you are using. If you are attaching a Wifi dongle then use a power supply providing a minimum of 1.5A (some of the later Raspberry Pis, which have Wifi, need more than this anyway).

If it has both Wifi and an ethernet port:

- Connect the Raspberry Pi to your router using an ethernet cable
- Insert the SD card
- Connect it to a power supply

If it has an ethernet port and no wifi:

- Connect the Raspberry Pi to your router using an ethernet cable
- Connect a Wifi dongle to one of the Raspberry Pi's USB ports
- Insert the SD card
- Connect it to a power supply

Not all Wifi dongles are supported by the Linux kernel. See [this page](https://elinux.org/RPi_USB_Wi-Fi_Adapters) for details of which are compatible.

#### Accessing the Raspberry Pi via the terminal

You may be able to log into the Raspberry Pi with:

```
ssh pi@raspberrypi.local
```

However, if this doesn't work you will need to access your router's admin page via the browser. This will usually be 192.168.0.1 or 192.168.1.1. From there select the menu option to view attached devices and note down the IP address of the device named 'raspberrypi'. In my case this was 192.168.0.92. Then:

```
ssh pi@192.168.0.92
```

If accessing ssh via the IP addess was necessary and then doesn't work again after following some of the steps below, go back into your router's admin page and check that the IP address hasn't changed.

Enter 'yes' when asked at the prompt.

Enter 'raspberry' when asked for the password.

#### Basic housekeeping

Change the default password for the 'pi' user:

```
passwd
```

Then enter the current password ('raspberry') and your new password twice, as prompted.

The next step is to enlarge the data partition on the SD card. Enter:

```
sudo raspi-config
```

Select 'Advanced Options' and then 'Expand Filesystem'. Once this is complete you will be asked to reboot, so:

```
sudo reboot
```

...and you will be kicked out of ssh. Once the Raspberry Pi has had the chance to boot up again, log in via ssh again, this time using your new password when prompted:


```
ssh pi@192.168.0.92
```

## Setting up the access point

If you are using the setup script to configure the Raspberry Pi as an access point you do not need to complete the steps below.

### Installing required packages

When logged in via ssh, enter the folling commands, letting each complete in turn:

```
sudo apt update
sudo apt install hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

```

### Setting up the network bridge

Run:

```
sudo nano /etc/systemd/network/bridge-br0.netdev
```

and paste the following into the new, blank file:

```
[NetDev]
Name=br0
Kind=bridge
```

Press ctrl-X to close and save.

Now run:

```
sudo nano /etc/systemd/network/br0-member-eth0.network
```

...and paste in:

```
[Match]
Name=eth0

[Network]
Bridge=br0
```
Press ctrl-X to close and save.

Run the following command to initialise the bridge on boot:

```
sudo systemctl enable systemd-networkd
```

The Raspberry Pi's DHCP settings need changing so it requests an IP address from the connected router (see 'Requirements' above) for the bridge. To edit the config:

```
sudo nano /etc/dhcpcd.conf
```

Add the following to the very top of the file:

```
denyinterfaces wlan0 eth0
```

...and the following to the very bottom:

```
interface br0
```

### Setting up the wireless device

Enter the following to temporarily enable the Raspberry Pi's Wifi device, pending configuring it properly in the next steps:

```
sudo rfkill unblock wlan
```

Then:

```
sudo nano /etc/hostapd/hostapd.conf
```

...and paste the following into the new, blank file:

```
country_code=GB
interface=wlan0
bridge=br0
ssid=FREERADIUS_TESTING
hw_mode=g
channel=7
macaddr_acl=0
ieee8021x=1
nas_name=dockernet
auth_server_addr=192.168.0.47
auth_server_port=1812
auth_server_shared_secret=testing123
acct_server_addr=192.168.0.47
acct_server_port=1813
acct_server_shared_secret=testing123
```

If you are using a later Raspberry Pi 3 or a 4 then you can change `hw_mode=g` to `hw_mode=a` to enable 5Ghz but since we're just using this for testing FreeRADIUS authentication it's going to make little difference in practice.

Press ctrl-X to close and save.

Now, reboot the Raspberry Pi with:

```
sudo reboot
```
You should be able to connect to FreeRADIUS via the SSID 'FREERADIUS_TESTING'. If you are using the provided FreeRADIUS configuration, a variety of authentication methods will work using the username 'testing' and password 'password'.

