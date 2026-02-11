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

## Running Rails on VPS
- Ruby is managed via **rbenv** (`~/.rbenv/`) — not in default PATH
- Must init rbenv before running Rails commands:
  ```bash
  ssh hetzner-scraper 'export PATH="$HOME/.rbenv/bin:$PATH" && eval "$(rbenv init -)" && cd ~/projects/tikt && RAILS_ENV=production bin/rails runner "..."'
  ```
- For multi-line scripts: write `.rb` file locally, `scp` to VPS, then `bin/rails runner /tmp/script.rb` — avoids shell escaping issues (especially `!` in `create!`)
- App lives at `~/projects/tikt` on the VPS

## Production Data
- Insert time entries via `TimeEntry.create!(project: project, date:, hours:, description:)`
- Query clients/projects: `Client.all` → `client.projects`
- Query entries: `TimeEntry.joins(:project).where(projects: { client_id: ID }).order(:date)`

## Gotchas
- Nginx site filename is `tikt.bytebricks.ch`, not `tikt` — the symlink expects this exact name
- Shell escaping: `!` in Ruby bang methods (`create!`) gets mangled by bash heredocs and SSH quoting — always use SCP'd script files for production runners
