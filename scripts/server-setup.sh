#!/bin/bash
# Server setup script for TikT deployment
# Run this on the Hetzner VPS: ssh scraperuser@49.13.27.61

set -e

echo "=== TikT Server Setup ==="

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Check if Docker is installed
if command -v docker &> /dev/null; then
    echo "Docker already installed: $(docker --version)"
else
    echo "Installing Docker..."
    sudo apt install -y apt-transport-https ca-certificates curl
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

    # Add user to docker group
    sudo usermod -aG docker $USER
    echo "Docker installed. You'll need to logout and back in for group changes."
fi

# Create storage directory
echo "Creating storage directory..."
sudo mkdir -p /opt/tikt/storage
sudo chown $USER:$USER /opt/tikt

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

echo ""
echo "=== Setup Complete ==="
echo "Docker: $(docker --version 2>/dev/null || echo 'Need to logout/login')"
echo "Nginx: $(nginx -v 2>&1)"
echo "Certbot: $(certbot --version 2>&1)"
echo "Storage: /opt/tikt/storage"
echo ""
echo "IMPORTANT: If Docker was just installed, logout and login again:"
echo "  exit"
echo "  ssh scraperuser@49.13.27.61"
echo "  docker run hello-world"
