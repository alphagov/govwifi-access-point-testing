#!/bin/sh

iptables -t nat -D POSTROUTING -s ${SUBNET}/24 -j MASQUERADE > /dev/null 2>&1 || true
iptables -t nat -A POSTROUTING -s ${SUBNET}/24 -j MASQUERADE

iptables -D FORWARD -o ${INTERFACE} -m state --state RELATED,ESTABLISHED -j ACCEPT > /dev/null 2>&1 || true
iptables -A FORWARD -o ${INTERFACE} -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -D FORWARD -i ${INTERFACE} -j ACCEPT > /dev/null 2>&1 || true
iptables -A FORWARD -i ${INTERFACE} -j ACCEPT
