#!/usr/bin/env bash

# Ensure Bluetooth is powered on
bluetoothctl power on > /dev/null 2>&1

# 1. Fetch paired and discoverable devices
# This parses the mac addresses and device names cleanly
devices_list=$(bluetoothctl devices | awk '{print substr($0, index($0,$3)) " [" $2 "]"}')

if [ -z "$devices_list" ]; then
    rofi -e "No Bluetooth devices found!"
    exit 1
fi

# Window 1: Selection List (Pure white, no scrollbar, JetBrainsMono)
chosen_device=$(echo -e "$devices_list" | rofi -dmenu \
    -theme-str 'entry { text-color: #ffffff; placeholder: "Select Bluetooth Device..."; } prompt { text-color: #ffffff; } listview { scrollbar: false; }' \
    -p "Bluetooth:" -i | xargs)

[ -z "$chosen_device" ] && exit 0

# Extract the MAC address inside the brackets [XX:XX:XX:XX:XX:XX]
mac_address=$(echo "$chosen_device" | grep -oE '[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}')
device_name=$(echo "$chosen_device" | sed 's/ \[[0-9A-Fa-f:]*\]//')

# 2. Check current connection status of the chosen device
is_connected=$(bluetoothctl info "$mac_address" | grep "Connected: yes")

if [ -n "$is_connected" ]; then
    # If already connected, disconnect it cleanly
    notify-send "Bluetooth" "Disconnecting from $device_name..." -i bluetooth
    bluetoothctl disconnect "$mac_address" > /dev/null 2>&1
    notify-send "Bluetooth" "Disconnected from $device_name" -i bluetooth
else
    # If disconnected, trigger a quick pair/trust/connect lifecycle loop
    notify-send "Bluetooth" "Connecting to $device_name..." -i bluetooth
    
    # Run the background authentication handshake
    bluetoothctl trust "$mac_address" > /dev/null 2>&1
    bluetoothctl connect "$mac_address" > /dev/null 2>&1
    
    # Double check if it succeeded
    if bluetoothctl info "$mac_address" | grep -q "Connected: yes"; then
        notify-send "Bluetooth Connected" "Successfully synced with $device_name" -i bluetooth
    else
        rofi -font "JetBrainsMono Nerd Font 12" -e "Connection to $device_name failed!"
        notify-send "Bluetooth Error" "Failed to link with $device_name" -u critical -i bluetooth
    fi
fi
