class AddPositionToStories < ActiveRecord::Migration[8.0]
  def change
    add_column :stories, :position, :integer, null: false
    add_index :stories, [:project_id, :position], unique: true
  end
end
