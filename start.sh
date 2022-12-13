#!/bin/bash

export ROUTER_IP="$(/sbin/ip route | awk '/default/ { print $3 }')"

if [ -z "$INTERFACE" ]; then
    echo "No wireless interface specified, exiting"
    exit 1
fi

rfkill unblock wlan


cat > "/etc/hostapd/hostapd.conf"<<EOF
country_code=GB
interface=$INTERFACE
# bridge=br0
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
option domain-name-servers 8.8.8.8, 8.8.4.4;
option subnet-mask 255.255.255.0;
option routers ${ROUTER_IP};
subnet ${SUBNET} netmask 255.255.255.0 {
  range ${SUBNET::-1}100 ${SUBNET::-1}200;
}
EOF

cat /etc/hostapd/hostapd.conf
cat /etc/dhcpd.conf

/usr/bin/ip_tables.sh
dhcpd $INTERFACE
/usr/sbin/hostapd /etc/hostapd/hostapd.conf
