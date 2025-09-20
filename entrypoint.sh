#!/bin/sh
set -e

: "${PORT:=8080}"
: "${V2RAY_PORT:=10000}"
echo "[entrypoint] PORT=$PORT  V2RAY_PORT=$V2RAY_PORT"

# v2ray inbound 8080 ကို backend port သို့ ပြောင်း (Nginx က $PORT ကိုယူမယ်)
if grep -q '"port": 8080' /etc/v2ray/config.json 2>/dev/null; then
  sed -i 's/"port": 8080/"port": '"$V2RAY_PORT"'/g' /etc/v2ray/config.json
  echo "[entrypoint] inbound port -> $V2RAY_PORT"
fi

# v2ray start (background)
if command -v v2ray >/dev/null 2>&1; then
  v2ray -config /etc/v2ray/config.json &
else
  /usr/bin/v2ray -config /etc/v2ray/config.json &
fi
echo "[entrypoint] v2ray started"

# nginx.conf render (single file → include path issue ကိုကြေနှင်း)
mkdir -p /run/nginx
envsubst '$PORT $V2RAY_PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Debug logs (Cloud Logging တင်အောင်)
echo "[entrypoint] /etc/nginx/nginx.conf >>>"
sed -n '1,160p' /etc/nginx/nginx.conf || true
echo "<<< end"

echo "[entrypoint] ls /usr/share/nginx/html"
ls -l /usr/share/nginx/html || true

# Test & run
nginx -t
exec nginx -g 'daemon off;'