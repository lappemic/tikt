class AddStatusToProjectsAndSubprojects < ActiveRecord::Migration[8.1]
  def up
    add_column :projects, :status, :string, default: "offered", null: false
    add_column :subprojects, :status, :string, default: "offered", null: false
    add_index :projects, :status
    add_index :subprojects, :status

    # Migrate: active=true -> accepted, active=false -> rejected
    execute "UPDATE projects SET status = CASE WHEN active THEN 'accepted' ELSE 'rejected' END"
    execute "UPDATE subprojects SET status = CASE WHEN active THEN 'accepted' ELSE 'rejected' END"

    remove_column :projects, :active
    remove_column :subprojects, :active
  end

  def down
    add_column :projects, :active, :boolean, default: true, null: false
    add_column :subprojects, :active, :boolean, default: true, null: false

    execute "UPDATE projects SET active = (status = 'accepted' OR status = 'finished')"
    execute "UPDATE subprojects SET active = (status = 'accepted' OR status = 'finished')"

    remove_column :projects, :status
    remove_column :subprojects, :status
  end
end
