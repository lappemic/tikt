class AddBudgetToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :budget_cents, :integer
  end
end
