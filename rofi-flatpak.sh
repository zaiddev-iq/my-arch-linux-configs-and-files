#!/usr/bin/env bash

while true; do
    action=$(echo -e "🔥 Browse All Flathub Apps\n🔍 Search Apps Manually\n📦 Manage Installed Apps\n🔄 Check & Install Updates\n❌ Exit" | rofi -dmenu \
        -p "Flatpak Store" \
        -mesg "Flatpak App Manager Hub" \
        -theme-str '
            @import "/home/jazaydcvbnmk1/.cache/wal/colors-rofi.rasi"
            window { background-color: #0c0f12f0; border: 2px; border-color: #ff007f; border-radius: 12px; width: 500px; }
            mainbox { background-color: transparent; }
            element { background-color: transparent; text-color: #ffffff; padding: 8px; }
            element selected { background-color: #ff007f33; text-color: #ffffff; border-radius: 6px; }
            entry { enabled: false; }
            inputbar { enabled: false; }
            listview { scrollbar: false; margin: 0px; padding: 0px; fixed-height: false; dynamic: true; background-color: transparent; }
            textbox { text-color: #ffffff; padding: 10px; margin: 0px 0px 10px 0px; background-color: #ff007f33; border-radius: 6px; }
        ')

    [ -z "$action" ] || [ "$action" = "❌ Exit" ] && exit 0

    if [ "$action" = "🔥 Browse All Flathub Apps" ]; then
        # جلب القائمة بشكل صامت فوري دون إرسال إشعارات notify-send
        apps_list=$(flatpak remote-ls flathub --app --columns=name,application,description 2>/dev/null | awk -F'\t' '{print $1 " [" $2 "] - " $3}')
        
        if [ -z "$apps_list" ]; then
            rofi -e "Failed to fetch apps list. Check your internet connection."
            continue
        fi

        selected_app=$(echo -e "$apps_list" | rofi -dmenu -p "Search" -mesg "All Available Flathub Apps" -font "JetBrainsMono Nerd Font 12" \
            -theme-str '
                @import "/home/jazaydcvbnmk1/.cache/wal/colors-rofi.rasi"
                window { background-color: #0c0f12f0; border: 2px; border-color: #ff007f; border-radius: 12px; width: 750px; height: 500px; }
                mainbox { background-color: transparent; padding: 10px; }
                inputbar { enabled: true; background-color: #ff007f15; border-radius: 6px; padding: 10px; margin: 0px 0px 10px 0px; children: [ prompt,entry ]; }
                prompt { text-color: #ff007f; margin: 0px 10px 0px 0px; }
                entry { enabled: true; text-color: #ffffff; placeholder: "Type to search apps..."; placeholder-color: #ffffff55; }
                textbox { text-color: #ffffff; padding: 10px; margin: 0px 0px 10px 0px; background-color: #ff007f33; border-radius: 6px; }
                listview { scrollbar: false; margin: 0px; padding: 0px; fixed-height: false; dynamic: true; background-color: transparent; }
                element { background-color: transparent; text-color: #ffffff; padding: 8px; }
                element selected { background-color: #ff007f33; text-color: #ffffff; border-radius: 6px; }
            ')
        [ -z "$selected_app" ] && continue

        app_id=$(echo "$selected_app" | grep -oP '\[\K[^\]]+')
        app_name=$(echo "$selected_app" | awk -F' \\[' '{print $1}')

        if [ -n "$app_id" ]; then
            notify-send "Flatpak Store" "Installing $app_name...\nPlease wait." -i system-software-install
            flatpak install -y flathub "$app_id" > /dev/null 2>&1
            
            if [ $? -eq 0 ]; then
                notify-send "Flatpak Store" "$app_name has been installed successfully!" -i system-software-install
                rofi -e "$app_name installed successfully! 🎉"
            else
                notify-send "Flatpak Store" "Failed to install $app_name." -i dialog-error
            fi
        fi

    elif [ "$action" = "🔍 Search Apps Manually" ]; then
        query=$(rofi -dmenu -p "Write" -mesg "Enter application name to search..." -font "JetBrainsMono Nerd Font 12" \
            -theme-str '
                @import "/home/jazaydcvbnmk1/.cache/wal/colors-rofi.rasi"
                window { background-color: #0c0f12f0; border: 2px; border-color: #ff007f; border-radius: 12px; width: 450px; height: 140px; }
                mainbox { background-color: transparent; padding: 10px; }
                inputbar { enabled: true; background-color: #ff007f15; border-radius: 6px; padding: 10px; margin: 0px 0px 10px 0px; children: [ prompt,entry ]; }
                prompt { text-color: #ff007f; margin: 0px 10px 0px 0px; }
                entry { enabled: true; text-color: #ffffff; }
                textbox { text-color: #ffffff; padding: 10px; margin: 0px 0px 10px 0px; background-color: #ff007f33; border-radius: 6px; }
                listview { enabled: false; }
            ')
        [ -z "$query" ] && continue

        results=$(flatpak search "$query" --columns=application,name,description 2>/dev/null | awk -F'\t' '{print $2 " (" $1 ") - " $3}' | head -n 30)
        
        if [ -z "$results" ]; then
            rofi -e "No applications found matching '$query'"
            continue
        fi

        selected_app=$(echo -e "$results" | rofi -dmenu -p "Select App:" -mesg "Results for: $query" -font "JetBrainsMono Nerd Font 12" -theme-str 'window { width: 650px; }')
        [ -z "$selected_app" ] && continue

        app_id=$(echo "$selected_app" | grep -oP '\(\K[^)]+')
        app_name=$(echo "$selected_app" | awk -F' \\(' '{print $1}')

        if [ -n "$app_id" ]; then
            notify-send "Flatpak Store" "Installing $app_name...\nPlease wait." -i system-software-install
            flatpak install -y flathub "$app_id" > /dev/null 2>&1
            
            if [ $? -eq 0 ]; then
                notify-send "Flatpak Store" "$app_name has been installed successfully!" -i system-software-install
                rofi -e "$app_name installed successfully! 🎉"
            else
                notify-send "Flatpak Store" "Failed to install $app_name." -i dialog-error
            fi
        fi

    elif [ "$action" = "📦 Manage Installed Apps" ]; then
        installed=$(flatpak list --app --columns=name,application 2>/dev/null | awk -F'\t' '{print $1 " [" $2 "]"}')
        
        if [ -z "$installed" ]; then
            rofi -e "No Flatpak applications installed."
            continue
        fi

        selected_installed=$(echo -e "$installed" | rofi -dmenu -p "Uninstall:" -mesg "Select an application to remove" -font "JetBrainsMono Nerd Font 12" -theme-str 'window { width: 550px; }')
        [ -z "$selected_installed" ] && continue

        del_id=$(echo "$selected_installed" | grep -oP '\[\K[^\]]+')
        del_name=$(echo "$selected_installed" | awk -F' \[' '{print $1}')

        if [ -n "$del_id" ]; then
            notify-send "Flatpak Store" "Uninstalling $del_name..." -i system-software-install
            flatpak uninstall -y "$del_id" > /dev/null 2>&1
            notify-send "Flatpak Store" "$del_name has been removed." -i system-software-install
            rofi -e "$del_name has been removed. 📦"
        fi

    elif [ "$action" = "🔄 Check & Install Updates" ]; then
        notify-send "Flatpak Store" "Checking for updates..." -i software-update-available
        updates_check=$(flatpak update --nopull --dry-run 2>/dev/null)
        
        if echo "$updates_check" | grep -q "Nothing to do"; then
            notify-send "Flatpak Store" "Your Flatpak apps are already up to date!" -i software-update-available
            rofi -e "All applications are up to date! 🎉"
        else
            notify-send "Flatpak Store" "Updates found! Installing updates now..." -i software-update-available
            flatpak update -y > /dev/null 2>&1
            
            if [ $? -eq 0 ]; then
                notify-send "Flatpak Store" "All applications updated successfully!" -i software-update-available
                rofi -e "Updates installed successfully! 🔄"
            else
                notify-send "Flatpak Store" "Failed to complete updates." -i dialog-error
            fi
        fi
    fi
done
