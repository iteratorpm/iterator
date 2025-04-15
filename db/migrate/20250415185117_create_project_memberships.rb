class CreateProjectMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :project_memberships do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 1
      t.timestamps

      t.index [:project_id, :user_id], unique: true
    end
  end
end
