#!/usr/bin/env bash

# قائمة شاملة لأشهر الإيموجيز مجمعة ومصنفة
emojis="😀 Smiling Face\n😂 Joy Face\n🤣 ROFL\n😊 Smile\n🥰 Hearts Face\n😍 Heart Eyes\n🤩 Star Eyes\n😘 Blow Kiss\n😜 Wink Tongue\n🤔 Thinking\n🤫 Shush\n🥱 Yawn\n🙄 Roll Eyes\n🤨 Eyebrow Raise\n🥳 Party\n😎 Cool\n😭 Loud Crying\n😡 Angry\n💀 Skull\n💩 Poop\n👍 Thumbs Up\n👎 Thumbs Down\n❤️ Red Heart\n🔥 Fire\n✨ Sparkles\n🎉 Party Popper\n🚀 Rocket\n👑 Crown\n💡 Idea Light\n💯 100 Score"

# فتح نافذة Rofi بنفس مظهر وثيم سكربت الواي فاي (بدون scrollbar وبخط جيت برينز)
chosen=$(echo -e "$emojis" | rofi -dmenu -theme-str 'entry { text-color: #ffffff; placeholder: "Search Emojis..."; } prompt { text-color: #ffffff; } listview { scrollbar: false; }' -p "Emoji:" -i | xargs)

# الخروج إذا لم يتم اختيار شيء
[ -z "$chosen" ] && exit 0

# استخراج رمز الإيموجي فقط (الرمز الأول قبل المسافة)
emoji_char=$(echo "$chosen" | awk '{print $1}')

# 1. نسخ الإيموجي إلى الحافظة (Clipboard) لـ Wayland
echo -n "$emoji_char" | wl-copy

# 2. كتابة الإيموجي تلقائياً في مكان الماوس (Auto-Paste)
wtype "$emoji_char"

# إرسال إشعار منبثق يؤكد العملية
notify-send "Emoji Picker" "Copied and typed $emoji_char" -i input-keyboard
