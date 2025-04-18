class Integrations::GithubIntegration < ApplicationRecord
  has_one :integration, as: :provider

  # Configuration fields
  validates :api_url, presence: true
  validates :webhook_secret, presence: true
  validates :oauth_token, presence: true

  # Repositories this integration is connected to
  has_many :github_repositories

  # Webhook URL generation
  def webhook_url
    "#{ENV['APP_HOST']}/webhooks/github/#{integration.id}"
  end

  # For connecting multiple repositories
  def add_repository(repo_name, repo_id)
    github_repositories.find_or_create_by(
      name: repo_name,
      external_id: repo_id
    )
  end
end
