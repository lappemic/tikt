# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_03_055025) do
  create_table "clients", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.decimal "hourly_rate", precision: 10, scale: 2, default: "0.0"
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  create_table "invoice_line_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.integer "invoice_id", null: false
    t.decimal "quantity", precision: 8, scale: 2, null: false
    t.integer "time_entry_id"
    t.integer "total_cents", null: false
    t.integer "unit_price_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
    t.index ["time_entry_id"], name: "index_invoice_line_items_on_time_entry_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.date "due_at", null: false
    t.date "issued_at", null: false
    t.text "notes"
    t.string "number", null: false
    t.string "status", default: "draft", null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["number"], name: "index_invoices_on_number", unique: true
    t.index ["status"], name: "index_invoices_on_status"
  end

  create_table "projects", force: :cascade do |t|
    t.integer "budget_cents"
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.decimal "hourly_rate", precision: 10, scale: 2
    t.string "name", null: false
    t.string "status", default: "offered", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_projects_on_client_id"
    t.index ["status"], name: "index_projects_on_status"
  end

  create_table "subprojects", force: :cascade do |t|
    t.integer "budget_cents"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "project_id", null: false
    t.string "status", default: "offered", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_subprojects_on_project_id"
    t.index ["status"], name: "index_subprojects_on_status"
  end

  create_table "time_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "description"
    t.decimal "hours", precision: 5, scale: 2, null: false
    t.boolean "invoiced", default: false, null: false
    t.integer "project_id", null: false
    t.integer "subproject_id"
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_time_entries_on_date"
    t.index ["invoiced"], name: "index_time_entries_on_invoiced"
    t.index ["project_id"], name: "index_time_entries_on_project_id"
    t.index ["subproject_id"], name: "index_time_entries_on_subproject_id"
  end

  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoice_line_items", "time_entries"
  add_foreign_key "invoices", "clients"
  add_foreign_key "projects", "clients"
  add_foreign_key "subprojects", "projects"
  add_foreign_key "time_entries", "projects"
  add_foreign_key "time_entries", "subprojects"
end
