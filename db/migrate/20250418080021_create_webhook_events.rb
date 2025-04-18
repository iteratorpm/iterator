class CreateWebhookEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :webhook_events do |t|
      t.references :integration, null: false, foreign_key: true
      t.integer :status, default: 0
      t.integer :event_type, default: 0
      t.json :payload
      t.integer :attempts, default: 0
      t.datetime :last_attempt_at
      t.text :response
      t.timestamps
    end
  end
end
