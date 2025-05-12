class AddEpicToLabels < ActiveRecord::Migration[8.0]
  def change
    add_reference :labels, :epic, foreign_key: true, index: true
  end
end
