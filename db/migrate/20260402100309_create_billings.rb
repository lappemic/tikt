class CreateBillings < ActiveRecord::Migration[8.1]
  def change
    create_table :billings do |t|
      t.references :project, null: false, foreign_key: true
      t.date :date, null: false
      t.decimal :hours, precision: 5, scale: 2, null: false
      t.integer :amount_cents, null: false
      t.text :note

      t.timestamps
    end

    add_index :billings, :date
  end
end
