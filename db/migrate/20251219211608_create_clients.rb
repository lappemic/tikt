class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :address
      t.decimal :hourly_rate, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end
