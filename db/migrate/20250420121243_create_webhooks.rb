class CreateWebhooks < ActiveRecord::Migration[8.0]
  def change
    create_table :webhooks do |t|
      t.string :webhook_url
      t.boolean :enabled, default: false
      t.integer :failure_count, default: 0
      t.text :last_response_body
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
