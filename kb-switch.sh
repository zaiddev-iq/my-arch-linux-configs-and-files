#!/bin/bash

# قائمة اللغات المتاحة للعرض في Rofi
options="English\nArabic"

# تشغيل Rofi واختيار اللغة
chosen=$(echo -e "$options" | rofi -dmenu -p "اختر اللغة / Select Language:")

# تنفيذ التغيير بناءً على الاختيار
case $chosen in
    "English")
        hyprctl switchxkblayout all 0
        ;;
    "Arabic")
        hyprctl switchxkblayout all 1
        ;;
esac
