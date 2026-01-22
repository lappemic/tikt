# Clear existing data
InvoiceLineItem.destroy_all
Invoice.destroy_all
TimeEntry.destroy_all
Subproject.destroy_all
Project.destroy_all
Client.destroy_all

# Create clients
acme = Client.create!(
  name: "Acme Corp",
  email: "billing@acme.com",
  address: "123 Business Ave\nSan Francisco, CA 94102",
  hourly_rate: 150.00
)

startup = Client.create!(
  name: "TechStartup Inc",
  email: "accounts@techstartup.io",
  address: "456 Innovation Way\nAustin, TX 78701",
  hourly_rate: 125.00
)

freelance = Client.create!(
  name: "Local Business",
  email: "owner@localbiz.com",
  hourly_rate: 100.00
)

# Create projects with budgets and status
website = acme.projects.create!(name: "Website Redesign", budget: 5000.00, status: "accepted")
api = acme.projects.create!(name: "API Integration", hourly_rate: 175.00, budget: 8000.00, status: "accepted")

mvp = startup.projects.create!(name: "MVP Development", budget: 15000.00, status: "accepted")
mobile = startup.projects.create!(name: "Mobile App", status: "rejected")

consulting = freelance.projects.create!(name: "General Consulting", status: "accepted")

# Create Subprojects
website_design = website.subprojects.create!(name: "Design", description: "UI/UX design work", budget: 2000.00, status: "accepted")
website_dev = website.subprojects.create!(name: "Development", description: "Frontend implementation", budget: 2500.00, status: "accepted")
website_qa = website.subprojects.create!(name: "QA", description: "Testing and bug fixes", status: "accepted")

api_design = api.subprojects.create!(name: "API Design", budget: 3000.00, status: "accepted")
api_impl = api.subprojects.create!(name: "Implementation", budget: 4000.00, status: "accepted")

mvp_backend = mvp.subprojects.create!(name: "Backend", budget: 8000.00, status: "accepted")
mvp_frontend = mvp.subprojects.create!(name: "Frontend", budget: 5000.00, status: "accepted")

# Create time entries (last 30 days) with Subprojects
[
  [ website, website_design, 14.days.ago, 4.5, "Homepage design mockups" ],
  [ website, website_design, 13.days.ago, 3.0, "Navigation and footer components" ],
  [ website, website_dev, 10.days.ago, 6.0, "Responsive layout implementation" ],
  [ website, website_qa, 7.days.ago, 2.5, "Client feedback revisions" ],
  [ api, api_design, 12.days.ago, 5.0, "API endpoint design" ],
  [ api, api_impl, 11.days.ago, 4.0, "Authentication flow" ],
  [ api, api_impl, 8.days.ago, 3.5, "Testing and documentation" ],
  [ mvp, mvp_backend, 20.days.ago, 8.0, "Project setup and architecture" ],
  [ mvp, mvp_backend, 18.days.ago, 6.0, "User authentication" ],
  [ mvp, mvp_frontend, 15.days.ago, 7.0, "Core feature development" ],
  [ mvp, mvp_backend, 12.days.ago, 5.0, "Database schema design" ],
  [ mvp, mvp_frontend, 5.days.ago, 4.0, "Bug fixes and polish" ],
  [ consulting, nil, 6.days.ago, 2.0, "Strategy meeting" ],
  [ consulting, nil, 3.days.ago, 1.5, "Follow-up call" ],
  [ website, website_qa, Date.current, 2.0, "Final review meeting" ],
  [ mvp, mvp_frontend, Date.current, 3.0, "Sprint planning" ]
].each do |project, subproject, date, hours, description|
  project.time_entries.create!(
    subproject: subproject,
    date: date.to_date,
    hours: hours,
    description: description
  )
end

# Create a sample sent invoice (for TechStartup)
old_entries = mvp.time_entries.where(date: 20.days.ago..12.days.ago)
invoice = startup.invoices.create!(
  issued_at: 10.days.ago,
  due_at: 20.days.from_now,
  status: :sent
)

old_entries.each do |entry|
  invoice.line_items.create!(
    time_entry: entry,
    description: "#{entry.project.name}: #{entry.description}",
    quantity: entry.hours,
    unit_price_cents: (entry.hourly_rate * 100).to_i
  )
  entry.update!(invoiced: true)
end

puts "Seeded:"
puts "  #{Client.count} clients"
puts "  #{Project.count} projects"
puts "  #{Subproject.count} subprojects"
puts "  #{TimeEntry.count} time entries (#{TimeEntry.uninvoiced.count} uninvoiced)"
puts "  #{Invoice.count} invoices"
