class RenameStatusToState < ActiveRecord::Migration[8.0]
  def change
    rename_column :stories, :status, :state
    rename_column :reviews, :status, :state
    rename_column :csv_exports, :status, :state
    rename_column :webhook_events, :status, :state

    rename_column :notification_settings, :email_status, :email_state
    rename_column :notification_settings, :in_app_status, :in_app_state
    rename_column :notification_settings, :mute_status, :mute_state
  end
end
