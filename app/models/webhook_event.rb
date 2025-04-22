class WebhookEvent < ApplicationRecord
  belongs_to :integration

  enum :status, [:pending, :processed, :failed]
  enum :event_type, [:push, :pull_request, :issue, :commit_comment, :unknown]

  # Store the payload
  # serialize :payload, JSON

  # For tracking processing attempts
  attribute :attempts, :integer, default: 0
  attribute :last_attempt_at, :datetime
  attribute :response, :text
end
