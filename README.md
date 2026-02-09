# TikT

Time tracking and invoicing app for freelancers and small teams. Track time entries across clients, projects, and subprojects, then generate PDF invoices.

## Features

- **Clients** — manage client contacts and details
- **Projects & Subprojects** — organize work with budgets and status tracking
- **Time Entries** — log hours against projects/subprojects
- **Invoices** — generate and send invoices with line items, export as PDF
- **Dashboard** — overview of current work

## Tech Stack

- Ruby 3.4 / Rails 8.1
- SQLite (all environments)
- Hotwire (Turbo + Stimulus)
- Propshaft asset pipeline
- Puma web server
- Prawn for PDF generation

## Setup

```bash
git clone git@github.com:lappemic/tikt.git
cd tikt
bundle install
bin/rails db:setup
bin/dev
```

The app runs at `http://localhost:3000`.

## Testing

```bash
bin/rails test
```

## Deployment

Deployed on a Hetzner VPS with Nginx reverse-proxying to Puma. The site is password-protected via HTTP Basic Auth.

```bash
./scripts/deploy.sh
```

This SSHes into the VPS, pulls latest `main`, installs deps, runs migrations, precompiles assets, and restarts Puma.
