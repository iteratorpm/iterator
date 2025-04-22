class AddIterationFieldsToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :velocity, :integer
    add_column :projects, :automatic_planning, :boolean, default: true
  end
end
