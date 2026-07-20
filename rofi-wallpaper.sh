#!/usr/bin/env bash

CONF_FILE="/home/jazaydcvbnmk1/.config/hypr/hyprpaper.conf"
CACHE_DIR_FILE="/home/jazaydcvbnmk1/.cache/rofi-last-dir"
CACHE_WALL_FILE="/home/jazaydcvbnmk1/.cache/current_wallpaper"
THEME_FILE="/home/jazaydcvbnmk1/.local/share/color-schemes/pywal_theme.colors"

if [ -f "$CACHE_DIR_FILE" ]; then
    CURRENT_DIR=$(cat "$CACHE_DIR_FILE")
    [ ! -d "$CURRENT_DIR" ] && CURRENT_DIR="/home/jazaydcvbnmk1"
else
    CURRENT_DIR="/home/jazaydcvbnmk1"
fi

MONITOR=$(hyprctl monitors | grep "Monitor" | awk '{print $2}' | head -n 1)
[ -z "$MONITOR" ] && MONITOR="eDP-1"

if ! pgrep -x "hyprpaper" > /dev/null; then
    hyprpaper --config "$CONF_FILE" &
    until hyprctl hyprpaper instance >/dev/null 2>&1; do sleep 0.1; done
fi

while true; do
    options=".. [Go Back]"
    dirs=$(find "$CURRENT_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort)
    files=$(find "$CURRENT_DIR" -maxdepth 1 -mindepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -exec basename {} \; | sort)

    [ -n "$dirs" ] && options="$options\n$dirs"
    [ -n "$files" ] && options="$options\n$files"

    # هذا السطر المعدل سيقوم بإغلاق حقل الإدخال بالكامل وإخفاء عبارة Search apps... نهائياً من القائمة
    chosen=$(echo -e "$options" | rofi -dmenu \
        -mesg "Explorer: ${CURRENT_DIR/#\/home\/jazaydcvbnmk1/\~}" \
        -theme-str 'inputbar { enabled: false; } entry { enabled: false; }')

    [ -z "$chosen" ] && exit 0

    if [ "$chosen" = ".. [Go Back]" ]; then
        CURRENT_DIR=$(dirname "$CURRENT_DIR")
        echo "$CURRENT_DIR" > "$CACHE_DIR_FILE"
    elif [ -d "$CURRENT_DIR/$chosen" ]; then
        CURRENT_DIR="$CURRENT_DIR/$chosen"
        echo "$CURRENT_DIR" > "$CACHE_DIR_FILE"
    else
        FULL_PATH="$CURRENT_DIR/$chosen"
        REAL_PATH=$(realpath "$FULL_PATH")
        
        echo "$REAL_PATH" > "$CACHE_WALL_FILE"
        cat <<EOF > "$CONF_FILE"
preload = $REAL_PATH
wallpaper = $MONITOR,$REAL_PATH
splash = false
ipc = on
EOF
        
        hyprctl hyprpaper preload "$REAL_PATH" >/dev/null 2>&1
        hyprctl hyprpaper wallpaper "$MONITOR,$REAL_PATH" >/dev/null 2>&1
        
        wal -i "$REAL_PATH" -q
        
        if [ -f "/home/jazaydcvbnmk1/.cache/wal/colors.sh" ]; then
            source "/home/jazaydcvbnmk1/.cache/wal/colors.sh"
            
            hex_to_rgb() {
                local hex=${1/\#/}
                printf "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
            }
            
            BG=$(hex_to_rgb "$color0")
            FG=$(hex_to_rgb "$color15")
            ACCENT=$(hex_to_rgb "$color1")
            MUTED=$(hex_to_rgb "$color8")
            
            rm -f "$THEME_FILE"
            cat <<EOF > "$THEME_FILE"
[General]
Name=pywall_theme
ColorScheme=BreezeDark

[Colors:Button]
BackgroundNormal=$BG
ForegroundNormal=$FG

[Colors:View]
BackgroundNormal=$BG
ForegroundNormal=$FG
BackgroundAlternate=$BG

[Colors:Window]
BackgroundNormal=$BG
ForegroundNormal=$FG

[Colors:Selection]
BackgroundNormal=$ACCENT
ForegroundNormal=$FG

[Colors:Header]
BackgroundNormal=$BG
ForegroundNormal=$FG

[WM]
activeBackground=$ACCENT
activeForeground=$FG
inactiveBackground=$BG
inactiveForeground=$MUTED
EOF
            
            KWRITE="kwriteconfig6"
            command -v kwriteconfig5 >/dev/null && KWRITE="kwriteconfig5"
            $KWRITE --file kdeglobals --group General --key colorScheme "pywall_theme"
            
            dbus-send --session --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1
            qdbus org.kde.kwin /KWin reconfigure >/dev/null 2>&1
            
            if pgrep -x "dolphin" > /dev/null; then
                killall dolphin
                while pgrep -x "dolphin" >/dev/null; do sleep 0.05; done
                dolphin &
            fi
        fi
        
        pkill -SIGUSR2 waybar
        
        exit 0
    fi
done
