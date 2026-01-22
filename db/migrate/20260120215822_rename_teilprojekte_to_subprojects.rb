class RenameTeilprojekteToSubprojects < ActiveRecord::Migration[8.1]
  def change
    rename_table :teilprojekte, :subprojects
    rename_column :time_entries, :teilprojekt_id, :subproject_id
  end
end
