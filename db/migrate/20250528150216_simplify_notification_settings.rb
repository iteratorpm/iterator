class SimplifyNotificationSettings < ActiveRecord::Migration[8.0]
  def change
    change_table :notification_settings do |t|
      # Remove project-related columns and indexes
      t.remove :project_id
      t.remove_index name: "index_notification_settings_on_user_id_and_project_id"
      t.remove_index name: "index_notification_settings_on_user_id"

      # Add new columns for in_app and email settings
      t.integer :in_app_story_creation, default: 0
      t.integer :in_app_comments, default: 1
      t.integer :in_app_comment_source, default: 0
      t.integer :in_app_story_state_changes, default: 1
      t.integer :in_app_blockers, default: 1
      t.integer :in_app_comment_reactions, default: 1
      t.integer :in_app_reviews, default: 1

      t.integer :email_story_creation, default: 0
      t.integer :email_comments, default: 1
      t.integer :email_comment_source, default: 0
      t.integer :email_story_state_changes, default: 1
      t.integer :email_blockers, default: 1
      t.integer :email_comment_reactions, default: 1
      t.integer :email_reviews, default: 1

      # Remove old columns
      t.remove :story_creation
      t.remove :comments
      t.remove :comment_source
      t.remove :story_state_changes
      t.remove :blockers
      t.remove :comment_reactions
      t.remove :reviews
      t.remove :in_app_state
      t.remove :email_state
      t.remove :mute_state
    end

    # Update the user index to be unique since there's only one per user now
    add_index :notification_settings, :user_id, unique: true
  end
end
