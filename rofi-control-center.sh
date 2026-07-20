#!/usr/bin/env bash

# Define options without leading spaces
options="Wi-Fi Manager\nPower Profiles\nBluetooth\nWallpaper\nFonts"

# Launch Rofi with fixed lines and no complex theme crashes
chosen=$(echo -e "$options" | rofi -dmenu \
    -mesg "Settings" \
    -l 4 \
    -theme-str '
        entry { enabled: false; }
        inputbar { enabled: false; }
        listview { scrollbar: false; margin: 0px; padding: 0px; fixed-height: false; }
        textbox { text-color: #ffffff; padding: 10px; margin: 0px 0px 10px 0px; background-color: #ff007f33; border-radius: 6px; }
    ')

# Exit if window closed without a choice
[ -z "$chosen" ] && exit 0

# Route to the correct script depending on your choice
case "$chosen" in
    *"Wi-Fi"*)          ~/.config/rofi-wifi.sh ;;
    *"Clipboard"*)      ~/.config/rofi-clipboard.sh ;;
    *"Emoji"*)          ~/.config/rofi-emoji.sh ;;
    *"Power Profiles"*) ~/.config/rofi-power-profile.sh ;;
    *"Bluetooth"*)      ~/.config/rofi-bluetooth.sh ;;
    *"Power"*)          ~/.config/hypr/powermenu.sh ;;
    *"Wallpaper"*)      ~/.config/rofi-wallpaper.sh ;;
    *"Fonts"*)          ~/.local/bin/rofi-font-changer ;;
esac
