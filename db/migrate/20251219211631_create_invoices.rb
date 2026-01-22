class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :client, null: false, foreign_key: true
      t.string :number, null: false
      t.date :issued_at, null: false
      t.date :due_at, null: false
      t.string :status, default: "draft", null: false
      t.text :notes
      t.integer :total_cents, default: 0, null: false

      t.timestamps
    end

    add_index :invoices, :number, unique: true
    add_index :invoices, :status
  end
end
