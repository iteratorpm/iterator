class AddStateNotificationSettings < ActiveRecord::Migration[8.0]
  def change
    change_table :notification_settings do |t|
      t.integer :email_state, default: 1
      t.integer :in_app_state, default: 1
    end
  end
end
