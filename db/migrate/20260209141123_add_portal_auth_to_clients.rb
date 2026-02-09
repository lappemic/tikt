class AddPortalAuthToClients < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :password_digest, :string
    add_column :clients, :portal_enabled, :boolean, default: false, null: false
    add_index :clients, :email, unique: true
  end
end
