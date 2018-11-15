#!/bin/bash -ex

# Start a demo in access point mode with a local web server

. wfx_set_env
check_root

INTERFACE="wlan0"
ADDRESS="192.168.51.1/24"
DNSMASQ_CONF=$SILABS_ROOT/wfx_tools/demos/conf/dnsmasq.conf
HOSTAPD_CONF=$SILABS_ROOT/wfx_tools/demos/conf/hostapd.conf

# Check wlan0
if ! ip link show "$INTERFACE" &> /dev/null; then
    >&2 echo "Interface $INTERFACE not detected, exiting"
    exit 1
fi

# Kill potentially started process
kill_check wpa_supplicant hostapd dnsmasq wpa_gui

# Wait for potential termination of hostapd
sleep 1

# Tell dhcpcd to release WLAN interface
dhcpcd --release "$INTERFACE"

# Set static IP configuration
ip addr flush dev "$INTERFACE"
ip addr add "$ADDRESS" dev "$INTERFACE"
ip link set "$INTERFACE" up

# Start DHCP server
dnsmasq -C "$DNSMASQ_CONF"

# Start hostapd
# TODO: check why hostapd sometimes fails to restart (wlan0 busy)
hostapd -B "$HOSTAPD_CONF"

# TODO: start HTTP server with a static page
