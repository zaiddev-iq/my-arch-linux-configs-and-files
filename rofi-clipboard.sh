#!/usr/bin/env bash

# جلب قائمة الكاش وتخزينها في متغير مصفى
CLIP_LIST=$(cliphist list 2>/dev/null)

# التحقق من امتلاء الذاكرة
if [ -z "$CLIP_LIST" ]; then
    rofi -e "Clipboard is empty! Copy some text first."
    exit 0
fi

# إظهار نافذة Rofi ناصعة البياض بدون شريط التمرير المزعج
chosen=$(echo "$CLIP_LIST" | rofi -dmenu -theme-str 'entry { text-color: #ffffff; placeholder: "Search Clipboard..."; } prompt { text-color: #ffffff; } listview { scrollbar: false; }' -p "Clipboard:" -i)

# الخروج إذا تم إغلاق النافذة بدون اختيار
[ -z "$chosen" ] && exit 0

# فك التشفير ونسخ النص إلى حافظة النظام النشطة
echo "$chosen" | cliphist decode | wl-copy

# إشعار نجاح فوري على الشاشة
notify-send "Clipboard" "Text copied and ready to paste!" -i input-keyboard
