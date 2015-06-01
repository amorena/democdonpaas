#!/bin/bash -e
 
IFADDR="192.168.122.2/24"
 
if [[ ! ip link show docker0 ]]; then
ip link add docker0 type bridge
ip addr add "$IFADDR" dev docker0
ip link set docker0 up
iptables -t nat -A POSTROUTING -s "$IFADDR" ! -d "$IFADDR" -j MASQUERADE
fi
 
echo 1 > /proc/sys/net/ipv4/ip_forward 
