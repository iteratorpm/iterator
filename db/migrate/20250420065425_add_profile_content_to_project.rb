class AddProfileContentToProject < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :profile_content, :text
  end
end
