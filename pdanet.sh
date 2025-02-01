#!/bin/bash

# Run this script as root.

# Get the main network interface
MAIN_INTERFACE=$(ip route | grep default | awk '{print $5}')

# Get the origional route
ORIGINAL_ROUTE=$(ip route show | grep "^default" | head -n 1)

# Function to run when SIGINT (CTRL + C) is detected
cleanup() {
  echo "CTRL + C detected. Running cleanup..."
  # Undo tunnel interface and routes

  # 1. Stop tun2socks (if it's still running)
  killall tun2socks 2>/dev/null

  # 2. Remove the routes added by the first script
  ip route del default via 192.168.1.1 dev tun0 metric 1 2>/dev/null

  # Remove the default route added by the script
  ip route del default via 192.168.49.1 dev $MAIN_INTERFACE metric 10 2>/dev/null

  # 3. Restore your original default route dynamically
  ip route add $ORIGINAL_ROUTE

  # 4. Disable (and remove) the tunnel interface
  ip link set dev tun0 down 2>/dev/null
  ip tuntap del mode tun dev tun0 2>/dev/null

  # 5. Revert rp_filter to its default (usually 1)
  sysctl -w net.ipv4.conf.all.rp_filter=1
}

# Trap SIGINT and call the cleanup function
trap cleanup SIGINT

# Tunnel interface setup
ip tuntap add mode tun dev tun0
ip addr add 192.168.1.1/24 dev tun0
ip link set dev tun0 up
ip route del default
ip route add default via 192.168.1.1 dev tun0 metric 1
ip route add default via 192.168.49.1 dev $MAIN_INTERFACE metric 10

# Disable rp_filter to receive packets from other interfaces
sysctl -w net.ipv4.conf.all.rp_filter=0

# Run tun2socks
tun2socks -device tun://tun0 -interface $MAIN_INTERFACE -proxy socks5://192.168.49.1:8000
