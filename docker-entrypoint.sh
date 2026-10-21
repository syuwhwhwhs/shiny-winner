#!/bin/bash
set -e

APP=/var/www/html
PORT="${PORT:-8080}"
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

DOMAIN="${DOMAIN:-$RAILWAY_PUBLIC_DOMAIN}"
DB_HOST="${MYSQLHOST:-localhost}"
DB_PORT="${MYSQLPORT:-3306}"
DB_USER="${MYSQLUSER:-root}"
DB_PASS="${MYSQLPASSWORD:-}"
DB_NAME="${MYSQLDATABASE:-railway}"

# config.php از روی Environment Variables
cat > "$APP/config.php" <<PHP
<?php
\$request_exec_timeout = null;
\$dbhost = '${DB_HOST}';
\$dbname = '${DB_NAME}';
\$usernamedb = '${DB_USER}';
\$passworddb = '${DB_PASS}';
\$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci",
];
\$dsn = "mysql:host=\$dbhost;port=${DB_PORT};dbname=\$dbname;charset=utf8mb4";
try {
    \$pdo = new PDO(\$dsn, \$usernamedb, \$passworddb, \$options);
} catch (\PDOException \$e) {
    error_log("Database connection failed: " . \$e->getMessage());
    die("error: database connection failed");
}
\$APIKEY = '${BOT_TOKEN}';
\$adminnumber = '${ADMIN_ID}';
\$domainhosts = '${DOMAIN}';
\$usernamebot = '${BOT_USERNAME}';

?>
PHP
chown -R www-data:www-data "$APP/config.php" "$APP/storage"

# منتظر آماده شدن دیتابیس
for i in $(seq 1 30); do
  if php -r "try{new PDO('mysql:host=${DB_HOST};port=${DB_PORT};dbname=${DB_NAME}','${DB_USER}','${DB_PASS}');exit(0);}catch(Exception \$e){exit(1);}"; then
    echo "DB ready"; break
  fi
  echo "waiting for DB ($i/30)..."; sleep 2
done

# ساخت/آپدیت جدول‌ها و ست کردن webhook (خود table.php این کار را می‌کند)
if [ -n "$BOT_TOKEN" ] && [ -n "$DOMAIN" ]; then
  (cd "$APP" && runuser -u www-data -- php table.php) || echo "table.php failed"
else
  echo "BOT_TOKEN یا DOMAIN ست نشده؛ table.php اجرا نشد"
fi

# جایگزین کرون‌جاب: اجرای dispatcher هر ۶۰ ثانیه
(
  while true; do
    cd "$APP/cronbot" && runuser -u www-data -- php run.php >/dev/null 2>&1 || true
    sleep 60
  done
) &

exec apache2-foreground
