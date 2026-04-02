# TikT

**Time tracking, billing, and invoicing for freelancers and small teams.**

TikT is a self-hosted Rails app that handles the full freelance workflow: track hours across clients and projects, record what you actually billed, generate PDF invoices, and give clients a read-only portal to view their work.

Built with Rails 8.1, Hotwire, and SQLite. No JavaScript build step. No external database. Deploy anywhere with a single binary.

---

## Features

### Time Tracking
- Log hours against projects and subprojects
- Quick entry with dynamic subproject filtering
- Scoped views: today, this week, date ranges
- Real-time UI updates via Turbo Streams

### Billing
- Record billed hours and amounts independently of worked hours
- Auto-calculated amounts from project hourly rates (editable)
- Billing history per project with live create/delete
- Worked vs. billed delta tracking

### Invoicing
- Generate invoices from uninvoiced time entries
- Auto-numbered (INV-YYYY-001 format)
- PDF export with professional formatting (Prawn)
- Email delivery with PDF attachment
- Status workflow: draft > sent > paid
- Overdue detection

### Projects & Budgets
- Organize work into clients > projects > subprojects
- Budget tracking with progress bars and remaining calculations
- Status tracking: offered, accepted, rejected, finished
- Hourly rate inheritance: project > client > default
- Filterable overview with totals

### Client Portal
- Password-protected read-only portal for clients
- Clients can view their projects, time entries, and invoices
- Separate layout and navigation
- Rate-limited login (10 attempts/minute)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Ruby 3.4 / Rails 8.1 |
| Database | SQLite 3 |
| Frontend | Hotwire (Turbo + Stimulus) |
| Assets | Propshaft + Importmap (no build step) |
| PDF | Prawn + prawn-table |
| Background Jobs | Solid Queue |
| Caching | Solid Cache |
| WebSockets | Solid Cable |
| Server | Puma |
| Auth | bcrypt (portal), HTTP Basic Auth (admin) |
| Deployment | Docker / Kamal / bare metal |

---

## Getting Started

### Prerequisites

- Ruby 3.4+
- Bundler
- SQLite 3

### Setup

```bash
git clone https://github.com/lappemic/tikt.git
cd tikt
bundle install
bin/rails db:setup
bin/dev
```

Open `http://localhost:3000`. The seed data creates sample clients, projects, time entries, and an invoice to get started.

### Seed Data

`db:setup` loads demo data:
- 3 clients with hourly rates
- 5 projects across statuses with budgets
- 7 subprojects
- 16 time entries spanning 30 days
- 1 sent invoice with line items

---

## Database Schema

```
clients
  ├── projects
  │     ├── subprojects
  │     ├── time_entries
  │     └── billings
  └── invoices
        └── invoice_line_items ──> time_entries
```

9 models with full referential integrity, dependent destroys, and scoped queries.

---

## Deployment

TikT runs anywhere Ruby runs. Three options:

### Docker

```bash
docker build -t tikt .
docker run -p 3000:80 -e SECRET_KEY_BASE=$(bin/rails secret) tikt
```

The Dockerfile uses a multi-stage build with Thruster for HTTP caching/compression.

### Kamal

```bash
kamal setup
kamal deploy
```

### Bare Metal

```bash
git clone https://github.com/lappemic/tikt.git
cd tikt
bundle install --without development test
RAILS_ENV=production bin/rails db:setup
RAILS_ENV=production bin/rails assets:precompile
RAILS_ENV=production bin/rails server
```

Put Nginx or Caddy in front for TLS. A sample Nginx config is at `scripts/nginx-tikt.conf` and a systemd service file at `scripts/tikt.service`.

---

## Project Structure

```
app/
  controllers/        # 8 admin + 6 portal controllers
  models/             # 9 models (Client, Project, Subproject, TimeEntry, etc.)
  views/              # 38 ERB templates across admin + portal
  services/           # InvoiceGenerator (transaction-safe)
  pdfs/               # InvoicePdf (Prawn renderer)
  mailers/            # InvoiceMailer
  jobs/               # SendInvoiceJob (async delivery)
  javascript/
    controllers/      # 4 Stimulus controllers
scripts/
  deploy.sh           # SSH deploy script
  nginx-tikt.conf     # Nginx reverse proxy config
  tikt.service        # systemd unit file
```

---

## Design Decisions

**SQLite everywhere.** No Postgres, no Redis. Rails 8's Solid Queue, Solid Cache, and Solid Cable all run on SQLite. One less thing to configure and maintain.

**No JavaScript build step.** Importmap + Stimulus. The entire frontend is 4 small controller files. Turbo Streams handle real-time updates without writing any custom JavaScript for DOM manipulation.

**Billing decoupled from invoicing.** Worked hours and billed hours are independent. You might work 8 hours but bill 10 (or 6). Billing records exist separately from the invoice system.

**Cents everywhere.** All monetary values stored as integers (cents) to avoid floating-point issues. Helper methods convert for display.

**Two-layout architecture.** Admin and client portal are separate layouts with separate controllers and navigation. Portal controllers inherit from `Portal::BaseController` with session-based auth.

---

## Testing

```bash
bin/rails test
```

---

## License

[MIT](LICENSE)

---

Built by [@lappemic](https://github.com/lappemic)
