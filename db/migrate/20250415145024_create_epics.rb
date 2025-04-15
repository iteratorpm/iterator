class CreateEpics < ActiveRecord::Migration[8.0]
  def change
    create_table :epics do |t|
      t.string :title
      t.text :description
      t.references :project, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true
      t.string :external_link

      t.timestamps
    end
  end
end
