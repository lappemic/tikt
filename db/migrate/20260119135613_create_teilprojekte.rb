class CreateTeilprojekte < ActiveRecord::Migration[8.1]
  def change
    create_table :teilprojekte do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :budget_cents
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_reference :time_entries, :teilprojekt, foreign_key: { to_table: :teilprojekte }
  end
end
