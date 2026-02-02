#!/bin/bash
# Deploy script for TikT
# Usage: ./scripts/deploy.sh
# Runs on local machine, SSHes into VPS to deploy

set -e

VPS="scraperuser@49.13.27.61"
APP_DIR="~/projects/tikt"

echo "=== Deploying TikT ==="

ssh $VPS << 'DEPLOY'
set -e
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

cd ~/projects/tikt

echo "Pulling latest code..."
git pull origin main

echo "Installing dependencies..."
bundle install --without development test

echo "Running migrations..."
RAILS_ENV=production bin/rails db:migrate

echo "Precompiling assets..."
RAILS_ENV=production bin/rails assets:precompile

echo "Restarting Puma..."
sudo systemctl restart tikt

echo "Waiting for startup..."
sleep 3

if systemctl is-active --quiet tikt; then
    echo "=== Deploy successful! tikt is running ==="
else
    echo "=== Deploy FAILED! Checking logs... ==="
    journalctl -u tikt --no-pager -n 20
    exit 1
fi
DEPLOY

echo "=== Deployment complete ==="
echo "Verify: curl -I https://tikt.bytebricks.ch"
