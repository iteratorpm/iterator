class AddOrgColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :plan_type, :integer, default: 0, null: false
    add_column :organizations, :projects_count, :integer, default: 0
    add_column :organizations, :admins_count, :integer, default: 0
    add_column :organizations, :collaborators_count, :integer, default: 0

    add_column :projects, :members_count, :integer, default: 0
    add_column :projects, :stories_count, :integer, default: 0

    rename_column :projects, :project_start_date, :start_date
    rename_column :projects, :project_time_zone, :time_zone
  end
end
