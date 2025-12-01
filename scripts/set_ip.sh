#!/bin/bash

# Configuration Variables
# -----------------------
# Subnet mask 255.255.255.0 is equivalent to CIDR prefix /24
TARGET_IP="192.168.186.3/24"
INTERFACE="$1"

# Safety Checks
# -----------------------
# 1. Check for Root privileges
if [ "$EUID" -ne 0 ]; then 
  echo "Error: Please run this script as root (sudo)."
  exit 1
fi

# 2. Check if an interface name was provided
if [ -z "$INTERFACE" ]; then
  echo "Error: You must provide a network interface name."
  echo "Usage: sudo ./set_ip.sh <interface_name>"
  echo "Example: sudo ./set_ip.sh eth0"
  exit 1
fi

# 3. Check if the interface actually exists on the system
if ! ip link show "$INTERFACE" > /dev/null 2>&1; then
  echo "Error: Interface '$INTERFACE' does not exist."
  echo "Use 'ip link' to see available interfaces."
  exit 1
fi

# Execution
# -----------------------
echo "Configuring $INTERFACE..."

# Optional: Flush existing IPs to prevent conflicts (removes old IPs)
# Comment the line below out if you want to add this IP as a secondary alias instead.
ip addr flush dev "$INTERFACE"

# Set the new Static IP
ip addr add "$TARGET_IP" dev "$INTERFACE"

# Bring the interface up
ip link set "$INTERFACE" up

# Verification
# -----------------------
if ip addr show "$INTERFACE" | grep -q "192.168.186.3"; then
  echo "Success! IP $TARGET_IP assigned to $INTERFACE."
else
  echo "Failed to assign IP."
  exit 1
fi