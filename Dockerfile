FROM ubuntu:latest

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends rfkill systemctl python3 \
    iptables isc-dhcp-server iproute2 iw python3-pip hostapd && \
	systemctl unmask hostapd && \
	systemctl enable hostapd && \
	apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV INTERFACE = ""
ENV SUBNET="192.168.0.0"

COPY ip_tables.sh /usr/bin
RUN chmod 775 /usr/bin/ip_tables.sh
COPY start.sh /usr/bin
RUN chmod 775 /usr/bin/start.sh
COPY dhcpd.leases /var/lib/dhcp/

CMD ["/usr/bin/start.sh"]
