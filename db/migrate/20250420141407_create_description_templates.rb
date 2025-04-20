class CreateDescriptionTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :description_templates do |t|
      t.string :name
      t.text :description
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
