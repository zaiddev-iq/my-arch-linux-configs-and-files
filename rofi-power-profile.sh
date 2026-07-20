#!/usr/bin/env bash

# Define the profiles cleanly
options="   Performance\n   Balanced\n   Power Saver"

# Open Rofi without search bars
chosen=$(echo -e "$options" | rofi -dmenu -theme-str 'window { width: 300px; } entry { enabled: false; } prompt { enabled: false; } listview { scrollbar: false; lines: 3; }' -i)

# Exit if no selection was made
[ -z "$chosen" ] && exit 0

# FIX: Robust parsing to cleanly extract the exact matching lowercase profiles
if [[ "$chosen" == *"Performance"* ]]; then
    profile="performance"
elif [[ "$chosen" == *"Balanced"* ]]; then
    profile="balanced"
elif [[ "$chosen" == *"Power Saver"* ]]; then
    profile="power-saver"
fi

# Set the hardware power state cleanly
powerprofilesctl set "$profile"

# Push a desktop notification banner confirming it changed
notify-send "Power Profile Changed" "System hardware set to: $profile" -i battery-good
