#!/bin/bash

# Check if the script is running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

# Check command-line parameters
check_params() {
    if [ $# -ne 2 ]; then
        echo "Usage: $0 <IP_ADDRESS> <OPENVPN_CONFIG_PATH>"
        exit 1
    fi
}

# Perform nslookup and report success
perform_nslookup() {
    local domain="$1"
    if nslookup "$domain" &>/dev/null; then
        echo "[+] nslookup $domain successful"
    else
        echo "[-] nslookup $domain failed"
    fi
}

# Main script
main() {
    check_root
    check_params "$@"
    export THMDCIP="$1"
    local THMDCIP="$1"
    local OPENVPN_CONFIG="$2"
    #killing existiong openvpn connections:
    echo "Killing old openvpn session..."
    sudo pkill openvpn
    sleep 5
    # Start OpenVPN with the provided configuration file
    echo "Starting new openvpn session..."
    sudo openvpn --config "$OPENVPN_CONFIG" &

    # Wait for the connection to establish (adjust sleep time as needed)
    sleep 10

    # Check if THMDCIP is reachable
    if ping -c 1 "$THMDCIP" &>/dev/null; then
        echo "[+] $THMDCIP is reachable"

        # Backup the original /etc/resolv.conf
        cp /etc/resolv.conf /etc/resolv.conf.backup

        # Update /etc/resolv.conf
        echo -e "nameserver $THMDCIP \nnameserver 1.1.1.1 \noptions timeout:1 \noptions attempts:2" > /etc/resolv.conf
   #     echo "options timeout:1 attempts:2" >> /etc/resolv.conf

        # Restart networking service
        sudo systemctl restart networking.service

        # Perform nslookup checks and report success
        perform_nslookup thmdc.za.tryhackme.com
        perform_nslookup "tryhackme.com $THMDCIP"
        perform_nslookup tryhackme.com

        # Check if ntlmauth.za.tryhackme.com responds and report success
        if nslookup ntlmauth.za.tryhackme.com &>/dev/null; then
            echo "[+] ntlmauth.za.tryhackme.com is reachable"
        else
            echo "[-] ntlmauth.za.tryhackme.com is not reachable"
        fi
    else
        echo "[-] $THMDCIP is not reachable"
    fi
}

# Call the main function with command-line arguments
main "$@"
