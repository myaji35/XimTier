#!/usr/bin/env bash
# XimTier Let's Encrypt SSL 자동 발급 스크립트
#
# 사전 조건:
#   1) 도메인 구매 + DNS A 레코드를 158.247.235.31로 입력
#   2) DNS 전파 완료 (dig +short ${PRODUCTION_HOST} 결과가 IP와 일치)
#   3) Vultr 서버에서 실행 (또는 SSH 경유)
#
# 사용:
#   export PRODUCTION_HOST=ximtier.io
#   export ADMIN_EMAIL=admin@ximtier.io
#   bash _workspace/deploy/setup-ssl.sh
#
# 결과:
#   - /etc/nginx/sites-enabled/ximtier 배포 (HTTP+HTTPS)
#   - Let's Encrypt 인증서 자동 발급
#   - certbot 자동 갱신 cron 활성

set -euo pipefail

: "${PRODUCTION_HOST:?Set PRODUCTION_HOST (e.g. ximtier.io)}"
: "${ADMIN_EMAIL:?Set ADMIN_EMAIL (e.g. admin@ximtier.io)}"

VHOST_AVAILABLE=/etc/nginx/sites-available/ximtier
VHOST_ENABLED=/etc/nginx/sites-enabled/ximtier

echo "▶ [1/6] DNS 확인"
RESOLVED=$(dig +short "$PRODUCTION_HOST" | tail -1)
SERVER_IP=$(curl -s ifconfig.me)
if [ "$RESOLVED" != "$SERVER_IP" ]; then
  echo "❌ DNS not pointing to this server: $PRODUCTION_HOST → $RESOLVED (expected $SERVER_IP)"
  exit 1
fi
echo "  ✓ $PRODUCTION_HOST → $SERVER_IP"

echo "▶ [2/6] certbot 설치 확인"
if ! command -v certbot >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq certbot python3-certbot-nginx
fi
echo "  ✓ certbot $(certbot --version 2>&1 | head -1)"

echo "▶ [3/6] nginx vhost 배포 (HTTP only, ACME challenge용)"
mkdir -p /var/www/certbot
cat > "$VHOST_AVAILABLE" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $PRODUCTION_HOST ximtier.158.247.235.31.nip.io;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        proxy_pass http://127.0.0.1:3030;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;
        proxy_send_timeout 120s;
        client_max_body_size 100m;
    }
}
EOF
ln -sf "$VHOST_AVAILABLE" "$VHOST_ENABLED"
nginx -t && systemctl reload nginx
echo "  ✓ HTTP vhost 활성"

echo "▶ [4/6] Let's Encrypt 인증서 발급 (webroot)"
certbot certonly --webroot \
  -w /var/www/certbot \
  -d "$PRODUCTION_HOST" \
  --email "$ADMIN_EMAIL" \
  --agree-tos --non-interactive --no-eff-email
echo "  ✓ 인증서 발급 완료"

echo "▶ [5/6] HTTPS vhost 적용 (80 → 301 → 443)"
cat > "$VHOST_AVAILABLE" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $PRODUCTION_HOST;
    location /.well-known/acme-challenge/ { root /var/www/certbot; }
    location / { return 301 https://\$host\$request_uri; }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $PRODUCTION_HOST;

    ssl_certificate     /etc/letsencrypt/live/$PRODUCTION_HOST/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$PRODUCTION_HOST/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_session_cache   shared:SSL:10m;
    ssl_session_timeout 1d;

    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options DENY always;
    add_header Referrer-Policy strict-origin-when-cross-origin always;

    location / {
        proxy_pass http://127.0.0.1:3030;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;
        proxy_send_timeout 120s;
        client_max_body_size 100m;
    }
}

# nip.io 임시 도메인은 HTTP-only 유지 (TLS 인증서 없음)
server {
    listen 80;
    server_name ximtier.158.247.235.31.nip.io;
    location / {
        proxy_pass http://127.0.0.1:3030;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
nginx -t && systemctl reload nginx
echo "  ✓ HTTPS vhost 활성 (HSTS + A+ rating)"

echo "▶ [6/6] auto-renew cron 검증"
systemctl status certbot.timer --no-pager | head -5 || true
certbot renew --dry-run --quiet && echo "  ✓ 자동 갱신 시뮬레이션 PASS"

echo ""
echo "🎉 완료. https://$PRODUCTION_HOST 접속 확인."
echo "   추가: kamal-proxy의 deploy.yml proxy.host 를 $PRODUCTION_HOST 로 업데이트 + bin/kamal proxy reboot"
