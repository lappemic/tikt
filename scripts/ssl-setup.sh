#!/bin/bash
# SSL setup script for TikT
# Run this on the Hetzner VPS after DNS is configured

set -e

DOMAIN="tikt.bytebricks.ch"
EMAIL="${1:-your-email@example.com}"

echo "=== SSL Setup for $DOMAIN ==="

# Check DNS
echo "Checking DNS resolution..."
IP=$(dig +short $DOMAIN)
if [ -z "$IP" ]; then
    echo "ERROR: DNS not resolving for $DOMAIN"
    echo "Make sure the A record is set up in GoDaddy pointing to 49.13.27.61"
    exit 1
fi
echo "DNS resolves to: $IP"

# Create temporary HTTP-only config for certbot
echo "Creating temporary nginx config for certbot..."
sudo tee /etc/nginx/sites-available/$DOMAIN << 'EOF'
server {
    listen 80;
    server_name tikt.bytebricks.ch;
    location /.well-known/acme-challenge/ { root /var/www/html; }
    location / { return 503; }
}
EOF

sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Get certificate
echo "Requesting SSL certificate..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

# Now copy the full nginx config
echo "Updating nginx config with SSL settings..."
# The full config will be copied from scripts/nginx-tikt.conf

echo ""
echo "=== SSL Setup Complete ==="
echo "Certificate obtained for $DOMAIN"
echo ""
echo "Next steps:"
echo "1. Copy scripts/nginx-tikt.conf to /etc/nginx/sites-available/$DOMAIN"
echo "2. Run: sudo nginx -t && sudo systemctl reload nginx"
echo "3. Verify: sudo certbot renew --dry-run"
