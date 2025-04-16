class RemoveOrgUser < ActiveRecord::Migration[8.0]
  def change
    remove_column :organizations, :user_id
  end
end
