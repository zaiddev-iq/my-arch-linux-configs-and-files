#!/bin/bash
CONF="/home/jazaydcvbnmk1/.config/hypr/hyprpaper.conf"
C_WAL="/home/jazaydcvbnmk1/.cache/current_wallpaper"
THEME_FILE="/home/jazaydcvbnmk1/.local/share/color-schemes/pywal_theme.colors"
hyprctl reload
wal -R > /dev/null 2>&1
if [ -f "$C_WAL" ]; then
    W=$(cat "$C_WAL")
    if [ -f "$W" ]; then
        echo -e "preload = $W
wallpaper = eDP-1,$W
splash = false
ipc = on" > "$CONF"
        wal -i "$W" -q
        if [ -f "/home/jazaydcvbnmk1/.cache/wal/colors.sh" ]; then
            hex_to_rgb() {
                local hex=${1/\#/}
                printf "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
            }
            BG=$(hex_to_rgb "$color0")
            FG=$(hex_to_rgb "$color15")
            ACCENT=$(hex_to_rgb "$color1")
            MUTED=$(hex_to_rgb "$color8")
            rm -f "$THEME_FILE"
            echo -e "[General]
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
inactiveForeground=$MUTED" > "$THEME_FILE"
            KWRITE="kwriteconfig6"
            command -v kwriteconfig5 >/dev/null && KWRITE="kwriteconfig5"
            $KWRITE --file kdeglobals --group General --key colorScheme "pywall_theme"
            dbus-send --session --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1
            qdbus org.kde.kwin /KWin reconfigure >/dev/null 2>&1
        fi
    fi
fi
pkill -SIGUSR2 waybar
if pgrep -x "hyprpaper" > /dev/null; then
    hyprctl hyprpaper preload "$W" >/dev/null 2>&1
    hyprctl hyprpaper wallpaper "eDP-1,$W" >/dev/null 2>&1
else
    hyprpaper --config "$CONF" &
fi
