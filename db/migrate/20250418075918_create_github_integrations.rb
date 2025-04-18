class CreateGithubIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :github_integrations do |t|
      t.string :api_url
      t.string :webhook_secret
      t.string :oauth_token
      t.string :oauth_refresh_token
      t.datetime :oauth_expires_at
      t.timestamps
    end
  end
end
