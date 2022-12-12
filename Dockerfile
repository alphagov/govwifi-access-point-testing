FROM ubuntu:latest

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends systemctl hostapd && \
	systemctl unmask hostapd && \
	systemctl enable hostapd && \
	apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir -p /etc/systemd/network

RUN echo "[NetDev]\nName=br0\nKind=bridge\n" > /etc/systemd/network/bridge-br0.netdev

RUN echo "[Match]\nName=eth0\n[Network]\nBridge=br0\n"

# sudo systemctl enable systemd-networkd
# RUN systemctl start systemd-networkd

RUN echo 'denyinterfaces wlan0 eth0' | cat - /etc/dhcpcd.conf > temp && mv temp /etc/dhcpcd.conf

RUN echo "interface br0" >> /etc/dhcpcd.conf

RUN rfkill unblock wlan

RUN echo \
"country_code=GB\n \
interface=wlan0\n \
bridge=br0\n \
ssid=FREERADIUS_TESTING\n \
hw_mode=g\n \
channel=7\n \
macaddr_acl=0\n \
ieee8021x=1\n \
nas_name=dockernet\n \
auth_server_addr=192.168.0.47\n \
auth_server_port=1812\n \
auth_server_shared_secret=testing123\n \
acct_server_addr=192.168.0.47\n \
acct_server_port=1813\n \
acct_server_shared_secret=testing123\n\n" \
>> /etc/hostapd/hostapd.conf

