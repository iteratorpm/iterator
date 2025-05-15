class AddProjectEpicIdToEpics < ActiveRecord::Migration[8.0]
  def change
    add_column :epics, :project_epic_id, :integer, null: false

    add_index :epics, [:project_id, :project_epic_id], unique: true
  end
end
