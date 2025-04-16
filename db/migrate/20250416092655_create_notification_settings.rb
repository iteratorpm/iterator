class CreateNotificationSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, foreign_key: true

      # Global notification preferences
      t.integer :story_creation, default: 0
      t.integer :comments, default: 1
      t.integer :comment_source, default: 0
      t.integer :story_state_changes, default: 1
      t.integer :blockers, default: 1
      t.integer :comment_reactions, default: 1
      t.integer :reviews, default: 1

      # Delivery methods
      t.integer :in_app_status, default: 1
      t.integer :email_status, default: 1

      # For project-specific settings
      t.integer :mute_status, default: 0

      t.timestamps
    end

    add_index :notification_settings, [:user_id, :project_id], unique: true
  end
end
