class RenameOrgOwnerToUser < ActiveRecord::Migration[8.0]
  def change
    remove_column :organizations, :owner_id
  end
end
