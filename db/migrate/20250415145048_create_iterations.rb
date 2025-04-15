class CreateIterations < ActiveRecord::Migration[8.0]
  def change
    create_table :iterations do |t|
      t.date :starts_on
      t.date :ends_on
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
