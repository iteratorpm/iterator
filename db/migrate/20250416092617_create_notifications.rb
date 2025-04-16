class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, foreign_key: true
      t.references :notifiable, polymorphic: true
      t.integer :notification_type, null: false
      t.integer :delivery_method, null: false, default: 0
      t.datetime :read_at
      t.text :message

      t.timestamps
    end

    add_index :notifications, [:user_id, :read_at]
  end
end
