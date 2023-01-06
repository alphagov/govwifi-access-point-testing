#!/bin/bash

if [ -z "$FREERADIUS_IP" ]; then
    echo "You must set a value for the FREERADIUS_IP environment variable before running this script."
    exit 0
fi

AP_INTERFACE=wlan0
LAN_INTERFACE=eth0
SSID=FREERADIUS_TESTING

apt-get update
apt-get install hostapd
systemctl unmask hostapd
systemctl enable hostapd

cat > "/etc/systemd/network/bridge-br0.netdev"<<EOF
[NetDev]
Name=br0
Kind=bridge
EOF

cat > "/etc/systemd/network/br0-member-$LAN_INTERFACE.network"<<EOF
[Match]
Name=$LAN_INTERFACE
[Network]
Bridge=br0
EOF

systemctl enable systemd-networkd

cat > "/etc/hostapd/hostapd.conf"<<EOF
country_code=GB
interface=$AP_INTERFACE
bridge=br0
ssid=$SSID
hw_mode=g
channel=7
macaddr_acl=0
ieee8021x=1
# nas_name=dockernet
auth_server_addr=$FREERADIUS_IP
auth_server_port=1812
auth_server_shared_secret=testing123
EOF

cat > "/etc/dhcp/dhcpd.conf"<<EOF
denyinterfaces $AP_INTERFACE $LAN_INTERFACE
interface br0
EOF

echo "\ncountry=GB\n" >> "/etc/wpa_supplicant/wpa_supplicant.conf"

rfkill unblock wlan
