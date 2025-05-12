class RemoveEpicFromStories < ActiveRecord::Migration[8.0]
  def change
    remove_column :stories, :epic_id
  end
end
