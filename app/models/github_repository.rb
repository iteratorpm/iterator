class GithubRepository < ApplicationRecord
  belongs_to :github_integration, class_name: 'Integrations::GithubIntegration'

  validates :name, presence: true
  validates :external_id, presence: true

  # Webhook ID from GitHub
  attribute :webhook_id, :integer
end
