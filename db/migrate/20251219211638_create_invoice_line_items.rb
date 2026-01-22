class CreateInvoiceLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :invoice_line_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :time_entry, foreign_key: true
      t.string :description, null: false
      t.decimal :quantity, precision: 8, scale: 2, null: false
      t.integer :unit_price_cents, null: false
      t.integer :total_cents, null: false

      t.timestamps
    end
  end
end
