class CreateTimeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :time_entries do |t|
      t.references :project, null: false, foreign_key: true
      t.date :date, null: false
      t.decimal :hours, precision: 5, scale: 2, null: false
      t.text :description
      t.boolean :invoiced, default: false, null: false

      t.timestamps
    end

    add_index :time_entries, :date
    add_index :time_entries, :invoiced
  end
end
