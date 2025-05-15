class AddLabelTypeToLabels < ActiveRecord::Migration[8.0]
  def change
    add_column :labels, :label_type, :integer, default: 0, null: false
    remove_column :labels, :color
  end
end
