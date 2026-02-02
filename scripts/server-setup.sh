#!/bin/bash
# Server setup script for TikT deployment (native, no Docker)
# Run this on the Hetzner VPS: ssh scraperuser@49.13.27.61

set -e

echo "=== TikT Server Setup ==="

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install build dependencies for Ruby
echo "Installing build dependencies..."
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev \
  libyaml-dev libffi-dev libsqlite3-dev libvips-dev

# Install rbenv + ruby-build
if [ -d "$HOME/.rbenv" ]; then
    echo "rbenv already installed"
else
    echo "Installing rbenv..."
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

    # Add to bashrc if not already there
    if ! grep -q 'rbenv/bin' ~/.bashrc; then
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    fi
fi

# Ensure rbenv is in PATH for this script
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install Ruby 3.4.7
RUBY_VERSION="3.4.7"
if rbenv versions --bare | grep -q "^${RUBY_VERSION}$"; then
    echo "Ruby $RUBY_VERSION already installed"
else
    echo "Installing Ruby $RUBY_VERSION (this takes a few minutes)..."
    rbenv install $RUBY_VERSION
fi
rbenv global $RUBY_VERSION

echo "Ruby $(ruby --version)"

# Install bundler
gem install bundler

# Check if Nginx is installed
if command -v nginx &> /dev/null; then
    echo "Nginx already installed: $(nginx -v 2>&1)"
else
    echo "Installing Nginx..."
    sudo apt install -y nginx
fi

# Check if certbot is installed
if command -v certbot &> /dev/null; then
    echo "Certbot already installed: $(certbot --version)"
else
    echo "Installing Certbot..."
    sudo apt install -y certbot python3-certbot-nginx
fi

# Create storage directory
echo "Setting up storage directory..."
mkdir -p ~/projects/tikt/storage

echo ""
echo "=== Setup Complete ==="
echo "Ruby: $(ruby --version)"
echo "Bundler: $(bundle --version)"
echo "Nginx: $(nginx -v 2>&1)"
echo "Certbot: $(certbot --version 2>&1)"
echo ""
echo "Next steps:"
echo "  1. cd ~/projects/tikt && bundle install --without development test"
echo "  2. Copy config/master.key from local machine"
echo "  3. Run scripts/ssl-setup.sh your-email@example.com"
echo "  4. sudo cp scripts/tikt.service /etc/systemd/system/"
echo "  5. sudo systemctl enable --now tikt"
