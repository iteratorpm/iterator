class AddPositionToEpic < ActiveRecord::Migration[8.0]
  def change
    add_column :epics, :position, :integer, null: false
    add_index :epics, [:project_id, :position], unique: true
  end
end
