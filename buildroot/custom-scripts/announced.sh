#!/bin/sh
DEST_IP=200.135.86.79
DEST_PORT=7001
INTERFACE=eth0
[ ! -r /etc/default/announced ] || . /etc/default/announced
trap 'exit 0' INT TERM
while :; do
    IP_ADDRESS=$(ip -4 addr show dev "$INTERFACE" 2>/dev/null | awk '/inet / {sub(/\/.*/, "", $2); print $2; exit}')
    if [ -n "$IP_ADDRESS" ]; then
        HOSTNAME=$(hostname)
        MAC_ADDRESS=$(cat "/sys/class/net/$INTERFACE/address" 2>/dev/null)
        MESSAGE="IP Address: $IP_ADDRESS, Hostname: $HOSTNAME, MAC Addr: $MAC_ADDRESS"
        printf '%s\n' "$MESSAGE" | nc -u -w 1 "$DEST_IP" "$DEST_PORT" >/dev/null 2>&1 || :
    fi
    sleep 1
done
