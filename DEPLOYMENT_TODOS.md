# Deployment Todos - TikT to Hetzner VPS

## Environment
- **VPS IP:** 49.13.27.61
- **SSH User:** scraperuser
- **Domain:** tikt.bytebricks.ch
- **Registry:** ghcr.io/lappemic/tikt

---

## Pre-Deployment Tasks

### 1. Create GitHub Personal Access Token
- [ ] Go to: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
- [ ] Generate new token with scopes: `write:packages`, `read:packages`
- [ ] Save token locally:
  ```bash
  echo "ghp_your_token_here" > ~/.kamal_ghcr_token
  chmod 600 ~/.kamal_ghcr_token
  ```

### 2. Configure DNS (GoDaddy)
- [ ] Add A record for `bytebricks.ch`:
  - Host: `tikt`
  - Type: A
  - Points to: `49.13.27.61`
  - TTL: 600
- [ ] Verify DNS propagation:
  ```bash
  dig tikt.bytebricks.ch +short
  # Should return: 49.13.27.61
  ```

---

## Server Setup Tasks

### 3. Prepare Server
- [ ] SSH into server: `ssh scraperuser@49.13.27.61`
- [ ] Run server setup script or execute these commands:
  ```bash
  # Update system
  sudo apt update && sudo apt upgrade -y

  # Install Docker
  sudo apt install -y apt-transport-https ca-certificates curl
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

  # Add user to docker group
  sudo usermod -aG docker scraperuser

  # Logout and back in for group changes
  exit
  ```
- [ ] Verify Docker: `docker run hello-world`
- [ ] Create storage directory:
  ```bash
  sudo mkdir -p /opt/tikt/storage
  sudo chown scraperuser:scraperuser /opt/tikt
  ```

### 4. Install Nginx
- [ ] Install: `sudo apt install -y nginx`
- [ ] Verify: `nginx -v`

### 5. Set Up SSL with Certbot
- [ ] Install certbot: `sudo apt install -y certbot python3-certbot-nginx`
- [ ] Create temporary config for certbot:
  ```bash
  sudo tee /etc/nginx/sites-available/tikt.bytebricks.ch << 'EOF'
  server {
      listen 80;
      server_name tikt.bytebricks.ch;
      location /.well-known/acme-challenge/ { root /var/www/html; }
      location / { return 503; }
  }
  EOF
  sudo ln -sf /etc/nginx/sites-available/tikt.bytebricks.ch /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl reload nginx
  ```
- [ ] Get certificate:
  ```bash
  sudo certbot --nginx -d tikt.bytebricks.ch --non-interactive --agree-tos -m YOUR_EMAIL
  ```

### 6. Configure Nginx Reverse Proxy
- [ ] Copy `scripts/nginx-tikt.conf` to server:
  ```bash
  scp scripts/nginx-tikt.conf scraperuser@49.13.27.61:~
  ```
- [ ] On server, install the config:
  ```bash
  sudo cp ~/nginx-tikt.conf /etc/nginx/sites-available/tikt.bytebricks.ch
  sudo nginx -t && sudo systemctl reload nginx
  ```
- [ ] Verify auto-renewal: `sudo certbot renew --dry-run`

---

## Deployment Tasks

### 7. Deploy with Kamal
- [ ] First deployment (setup):
  ```bash
  bin/kamal setup
  ```
- [ ] Subsequent deployments:
  ```bash
  bin/kamal deploy
  ```

---

## Verification

### 8. Verify Deployment
- [ ] Check DNS: `dig tikt.bytebricks.ch +short`
- [ ] Check SSL: `curl -I https://tikt.bytebricks.ch`
- [ ] Check container (on server): `docker ps | grep tikt`
- [ ] View logs: `bin/kamal logs`
- [ ] Rails console: `bin/kamal console`

---

## Troubleshooting

**502 Bad Gateway:**
```bash
docker ps  # Check if container running
docker logs tikt-web --tail 50
```

**Container won't start:**
```bash
docker logs tikt-web  # Check for RAILS_MASTER_KEY or migration errors
```

**SSL issues:**
```bash
sudo certbot certificates
sudo certbot renew --force-renewal
```
