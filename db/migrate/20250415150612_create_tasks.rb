class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.text :description, null: false
      t.boolean :completed, default: false
      t.references :story, null: false, foreign_key: true

      t.timestamps

      t.index :completed
    end
  end
end
