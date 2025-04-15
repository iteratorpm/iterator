class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.references :owner, null: false, foreign_key: true
      t.integer :seats_limit
      t.integer :projects_limit

      t.timestamps
    end
  end
end
