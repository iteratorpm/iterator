class CreateStoryLabels < ActiveRecord::Migration[8.0]
  def change
    create_table :story_labels do |t|
      t.references :story, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true

      t.timestamps

      t.index [:story_id, :label_id], unique: true
    end
  end
end
