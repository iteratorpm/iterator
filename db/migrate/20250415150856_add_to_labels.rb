class AddToLabels < ActiveRecord::Migration[8.0]
  def change
    change_table :labels do |t|
      t.string :color

      t.index [:project_id, :name], unique: true
    end
  end
end
