class AddArchiedToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :archived, :boolean, default: false
  end
end
