#!/bin/bash

ot_img="$HOME/Downloads/rebot.png"
shutdown_img="$HOME/Downloads/shutdown.png"

options="Reboot\0icon\x1f${ot_img}\nShutdown\0icon\x1f${shutdown_img}"

# كود الثيم المستطيل مع خط JetBrainsMono وتصغير حجم الأيقونات إلى 36 بكسل
theme_str='window{width:400px;location:center;anchor:center;}entry{enabled:false;}listview{columns:2;lines:1;scrollbar:false;fixed-height:false;dynamic:true;spacing:15px;}element-icon{size:20px;background-color:transparent;}'

chosen=$(echo -e "$options" | rofi -dmenu -i -show-icons -theme-str "$theme_str")

case $chosen in
    "Reboot") systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
esac
