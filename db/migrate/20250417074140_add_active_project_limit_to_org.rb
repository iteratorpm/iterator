class AddActiveProjectLimitToOrg < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :active_projects_count, :integer, default: 0

    rename_column :organizations, :projects_limit, :project_limit
    rename_column :organizations, :seats_limit, :collaborator_limit
  end
end
