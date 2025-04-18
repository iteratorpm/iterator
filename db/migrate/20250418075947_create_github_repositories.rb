class CreateGithubRepositories < ActiveRecord::Migration[8.0]
  def change
    create_table :github_repositories do |t|
      t.references :github_integration, null: false, foreign_key: { to_table: :github_integrations }
      t.string :name, null: false
      t.string :external_id, null: false
      t.bigint :webhook_id
      t.timestamps

      t.index [:github_integration_id, :external_id], unique: true
    end
  end
end
