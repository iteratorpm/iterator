class CreateBlockers < ActiveRecord::Migration[8.0]
  def change
    create_table :blockers do |t|
      t.text :description, null: false
      t.boolean :resolved, default: false
      t.references :story, null: false, foreign_key: true
      t.references :blocker_story, foreign_key: { to_table: :stories }

      t.timestamps

      t.index :resolved
    end
  end
end
