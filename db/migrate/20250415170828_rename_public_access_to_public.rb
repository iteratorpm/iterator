class RenamePublicAccessToPublic < ActiveRecord::Migration[8.0]
  def change
    rename_column :projects, :public_access, :public
  end
end
