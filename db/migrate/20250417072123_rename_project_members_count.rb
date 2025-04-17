class RenameProjectMembersCount < ActiveRecord::Migration[8.0]
  def change
    rename_column :projects, :members_count, :project_memberships_count
  end
end
