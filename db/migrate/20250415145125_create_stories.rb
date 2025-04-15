class CreateStories < ActiveRecord::Migration[8.0]
  def change
    create_table :stories do |t|
      t.string :title, null: false
      t.text :description
      t.integer :story_type, default: 0
      t.integer :status, default: 0
      t.integer :priority, default: 2  # Adding priority field
      t.integer :points
      t.references :project, null: false, foreign_key: true
      t.references :requester, foreign_key: { to_table: :users }
      t.references :epic, foreign_key: true  # Optional association
      t.references :iteration, foreign_key: true  # Optional association

      t.timestamps

      t.index :story_type
      t.index :status
      t.index :priority
    end
  end
end
