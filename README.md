# Mirza Bot روی Railway

1. این ۴ فایل را در یک ریپوی گیت‌هاب بگذار: Dockerfile, docker-entrypoint.sh, railway.json, README.md
2. Railway: New Project > Deploy from GitHub repo > همین ریپو
3. New > Database > MySQL
4. Variables سرویس برنامه:
   - BOT_TOKEN, ADMIN_ID, BOT_USERNAME (بدون @)
   - MYSQLHOST = ${{MySQL.MYSQLHOST}}
   - MYSQLPORT = ${{MySQL.MYSQLPORT}}
   - MYSQLUSER = ${{MySQL.MYSQLUSER}}
   - MYSQLPASSWORD = ${{MySQL.MYSQLPASSWORD}}
   - MYSQLDATABASE = ${{MySQL.MYSQLDATABASE}}
5. Settings > Networking > Generate Domain (پورت: همان PORT که Railway می‌دهد)
6. بعد از دیپلوی، ربات خودش جدول‌ها را می‌سازد و webhook را ست می‌کند. در تلگرام /start بزن.

کرون‌جاب‌ها داخل همان کانتینر اجرا می‌شوند.
