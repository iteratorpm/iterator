class CreateMutedProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :muted_projects do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.integer :mute_type, default: 0

      t.timestamps
    end

    add_index :muted_projects, [:user_id, :project_id], unique: true
  end
end
