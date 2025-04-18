class Integration < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: 'User'

  validates :name, presence: true
  validates :project_id, presence: true
  validates :integration_type, presence: true

  enum :integration_type, {
    github: 0,
    github_enterprise: 1,
    bitbucket: 2,
    bitbucket_server: 3,
    gitlab: 4,
    gitlab_self_managed: 5,
    jira: 6,
    zendesk: 7,
    concourse: 8,
    jenkins: 9,
    generic: 10,
    other: 11,
    slack: 12,
    campfire: 13
  }

  has_many :webhook_events, dependent: :destroy

  # Returns the appropriate form partial path
  def form_partial
    "integrations/forms/#{integration_type}"
  end
end
