#!/bin/bash

apt-get update
apt-get install -y --no-install-recommends rfkill systemctl python3 iptables isc-dhcp-server iproute2 iw python3-pip hostapd

rfkill unblock wlan

sudo systemctl unmask hostapd
sudo systemctl enable hostapd

cat > "/etc/systemd/network/bridge-br0.netdev"<<EOF
[NetDev]
Name=br0
Kind=bridge
EOF

cat "/etc/systemd/network/br0-member-eth0.network"<<EOF
[Match]
Name=eth0
[Network]
Bridge=br0
EOF

cat > "/etc/hostapd/hostapd.conf"<<EOF
country_code=GB
interface=$INTERFACE
bridge=br0
ssid=FREERADIUS_TESTING
hw_mode=g
channel=7
macaddr_acl=0
ieee8021x=1
# nas_name=dockernet
auth_server_addr=127.0.0.1
auth_server_port=1812
auth_server_shared_secret=testing123
EOF

cat > "/etc/dhcp/dhcpd.conf"<<EOF
denyinterfaces $INTERFACE eth0
interface br0
EOF

rfkill unblock wlan

sudo systemctl unmask hostapd
sudo systemctl enable hostapd

systemctl enable systemd-networkd

# systemctl unmask hostapd
# systemctl enable hostapd

cat /etc/hostapd/hostapd.conf
cat /etc/dhcpd.conf
cat /etc/systemd/network/br0-member-eth0.network
cat /etc/systemd/network/bridge-br0.netdev

# dhcpd $INTERFACE
# /usr/sbin/hostapd /etc/hostapd/hostapd.conf