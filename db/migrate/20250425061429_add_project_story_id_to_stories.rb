class AddProjectStoryIdToStories < ActiveRecord::Migration[8.0]
  def change
    add_column :stories, :project_story_id, :integer, null: false

    add_index :stories, [:project_id, :project_story_id], unique: true
  end
end
