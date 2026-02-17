#!/usr/bin/env bash
set -euo pipefail

# Log to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Actualiza e instala paquetes base (Amazon Linux 2023 usa dnf)
dnf -y update
dnf -y install nginx php php-fpm php-cli php-mysqlnd php-json php-gd php-mbstring jq git unzip awscli

# Configura PHP-FPM
sed -i 's/^user = .*/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/^group = .*/group = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/^listen = .*/listen = 127.0.0.1:9000/' /etc/php-fpm.d/www.conf

# Configura Nginx para servir PHP
cat >/etc/nginx/conf.d/app.conf <<'NGINX'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/html/public;

    index index.php index.html;

    location /health {
        return 200 'OK';
        add_header Content-Type text/plain;
    }

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include        /etc/nginx/fastcgi_params;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param  PATH_INFO $fastcgi_path_info;
    }
}
NGINX

mkdir -p /var/www/html/public
chown -R nginx:nginx /var/www/html

# Obtiene secretos de Nuvei y DB de Secrets Manager (requiere rol IAM con permisos)
NUVEI_SECRET_NAME="${NUVEI_SECRET_NAME:-nuvei/credentials}"
DB_SECRET_NAME="${DB_SECRET_NAME:-db/credentials}"

NUVEI_JSON=$(aws secretsmanager get-secret-value --secret-id "$NUVEI_SECRET_NAME" --query SecretString --output text || echo '{}')
DB_JSON=$(aws secretsmanager get-secret-value --secret-id "$DB_SECRET_NAME" --query SecretString --output text || echo '{}')

NUVEI_MERCHANT_ID=$(echo "$NUVEI_JSON" | jq -r '.merchantId // empty')
NUVEI_TERMINAL_ID=$(echo "$NUVEI_JSON" | jq -r '.terminalId // empty')
NUVEI_SECRET_KEY=$(echo "$NUVEI_JSON" | jq -r '.secretKey // empty')
NUVEI_BASE_URL=$(echo "$NUVEI_JSON" | jq -r '.baseUrl // empty')

DB_HOST=$(echo "$DB_JSON" | jq -r '.host // empty')
DB_USER=$(echo "$DB_JSON" | jq -r '.username // empty')
DB_PASS=$(echo "$DB_JSON" | jq -r '.password // empty')
DB_NAME=$(echo "$DB_JSON" | jq -r '.dbname // empty')

cat >/etc/app.env <<EOF
NUVEI_MERCHANT_ID=${NUVEI_MERCHANT_ID}
NUVEI_TERMINAL_ID=${NUVEI_TERMINAL_ID}
NUVEI_SECRET_KEY=${NUVEI_SECRET_KEY}
NUVEI_BASE_URL=${NUVEI_BASE_URL}
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
DB_NAME=${DB_NAME}
EOF

# App PHP de ejemplo (index.php) leyendo env vars para comprobar conectividad
cat >/var/www/html/public/index.php <<'PHP'
<?php
header('Content-Type: text/plain');

$env = parse_ini_file('/etc/app.env');
echo "Marketplace en PHP on AWS\n";
echo "DB Host: " . ($env['DB_HOST'] ?? 'N/A') . "\n";
echo "Nuvei Merchant: " . ($env['NUVEI_MERCHANT_ID'] ?? 'N/A') . "\n";

$mysqli = @new mysqli($env['DB_HOST'] ?? '', $env['DB_USER'] ?? '', $env['DB_PASS'] ?? '', $env['DB_NAME'] ?? '');
echo "MySQL connection: " . ($mysqli && !$mysqli->connect_errno ? "OK" : ("ERROR: " . ($mysqli->connect_error ?? 'no conn'))) . "\n";
PHP

# Habilita y arranca servicios
systemctl enable php-fpm nginx
systemctl restart php-fpm nginx
