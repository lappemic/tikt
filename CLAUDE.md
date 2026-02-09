# TikT

Rails app for time tracking, deployed on Hetzner VPS.

## Stack
- Ruby on Rails (production on Puma)
- SQLite (production DB)
- Nginx reverse proxy → Puma on port 3000
- Deployed via `scripts/deploy.sh` (SSH + git pull)

## Deployment
- **VPS**: Hetzner (`ssh hetzner-scraper`)
- **Domain**: tikt.bytebricks.ch
- **Deploy**: `./scripts/deploy.sh` — pulls latest main, bundles, migrates, precompiles, restarts Puma
- **Nginx config**: `scripts/nginx-tikt.conf` → deployed to `/etc/nginx/sites-available/tikt.bytebricks.ch`
  - Symlink: `/etc/nginx/sites-enabled/tikt.bytebricks.ch` → `/etc/nginx/sites-available/tikt.bytebricks.ch`
  - After updating config: `scp` to server, then `sudo cp` + `sudo nginx -t && sudo systemctl reload nginx`

## HTTP Basic Auth
- Site is password-protected via Nginx `auth_basic`
- Credentials: `admin` / `MiGoesHard`
- htpasswd file: `/etc/nginx/.htpasswd`
- Avoid special characters (`!`, `@`, `$`) in passwords — browsers mangle them in HTTP Basic Auth encoding

## Gotchas
- Nginx site filename is `tikt.bytebricks.ch`, not `tikt` — the symlink expects this exact name
