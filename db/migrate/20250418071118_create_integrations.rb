class CreateIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :integrations do |t|
      t.references :project, null: false
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :integration_type, null: false
      t.string :provider_type
      t.bigint :provider_id
      t.json :config
      t.json :scopes, default: []
      t.timestamps

      t.index [:provider_type, :provider_id]
    end
  end
end
