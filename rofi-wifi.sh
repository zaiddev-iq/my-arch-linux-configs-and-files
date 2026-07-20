#!/usr/bin/env bash
nmcli radio wifi on

PASS_DIR="$HOME/.config/rofi-passwords"
wifi_list=$(nmcli --fields SSID device wifi list | sed 1d | grep -v "^--" | awk '!seen[$0]++')

# 1. قائمة اختيار الشبكات (بدون شريط تمرير وخط جيت برينز)
chosen_network=$(echo "$wifi_list" | rofi -dmenu -theme-str 'entry { text-color: #ffffff; placeholder: "Select Wi-Fi Network..."; } prompt { text-color: #ffffff; } listview { scrollbar: false; }' -p "Wi-Fi:" -i | xargs)
[ -z "$chosen_network" ] && exit 0

if [ -f "$PASS_DIR/$chosen_network" ]; then
    wifi_pass=$(cat "$PASS_DIR/$chosen_network" | xargs)
    notify-send "Wi-Fi" "Connecting to saved network: $chosen_network..." -i network-wireless
    
    nmcli connection delete id "$chosen_network" > /dev/null 2>&1
    connect_output=$(nmcli --wait 15 device wifi connect "$chosen_network" password "$wifi_pass" 2>&1)
    
    if [[ $? -eq 0 ]]; then
        ip_addr=$(nmcli -g IP4.ADDRESS device show | head -n1)
        notify-send "Wi-Fi Connected" "Successfully linked to $chosen_network\nIP: $ip_addr" -i network-wireless
    else
        rm -f "$PASS_DIR/$chosen_network"
        notify-send "Wi-Fi Error" "Saved password failed. Saved file removed!" -u critical -i network-error
        
        # FIX: إضافة الخط هنا لنافذة الخطأ عند فشل كلمة المرور المحفوظة
        rofi -font "JetBrainsMono Nerd Font 12" -e "Saved password failed! File removed. Please try connecting again."
    fi
else
    # 2. نافذة إدخال كلمة المرور المنبثقة
    raw_pass=$(rofi -dmenu -password -font "JetBrainsMono Nerd Font 12" -theme-str 'window { location: center; anchor: center; width: 400px; } listview { enabled: false; } entry { text-color: #ffffff; placeholder: "Enter Password:"; } prompt { enabled: false; }' -i)
    wifi_pass=$(echo "$raw_pass" | xargs)
    
    if [ -n "$wifi_pass" ] ; then
        notify-send "Wi-Fi" "Authenticating with $chosen_network..." -i network-wireless
        nmcli connection delete id "$chosen_network" > /dev/null 2>&1
        connect_output=$(nmcli --wait 15 device wifi connect "$chosen_network" password "$wifi_pass" 2>&1)
        
        if [[ $? -eq 0 ]]; then
            echo "$wifi_pass" > "$PASS_DIR/$chosen_network"
            chmod 600 "$PASS_DIR/$chosen_network"
            ip_addr=$(nmcli -g IP4.ADDRESS device show | head -n1)
            notify-send "Wi-Fi Connected" "Successfully linked to $chosen_network\nIP: $ip_addr" -i network-wireless
        else
            nmcli connection delete id "$chosen_network" > /dev/null 2>&1
            notify-send "Wi-Fi Error" "Authentication failed for $chosen_network" -u critical -i network-error
            
            # FIX: إضافة الخط هنا لنافذة الخطأ الأساسية عند كتابة باسوورد خاطئ
            rofi -font "JetBrainsMono Nerd Font 12" -e "Wrong Password! Connection to $chosen_network failed."
        fi
    else
        nmcli device wifi connect "$chosen_network"
    fi
fi
