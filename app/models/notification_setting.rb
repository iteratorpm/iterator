class NotificationSetting < ApplicationRecord
  belongs_to :user

  # In-app notification enums
  enum :in_app_story_creation, { no: 0, yes: 1 }, prefix: :in_app_story_creation
  enum :in_app_comments, { none: 0, mentions_only: 1, all: 2 }, prefix: :in_app_comments
  enum :in_app_comment_source, { all_sources: 0, exclude_commits: 1 }, prefix: :in_app_comment_source
  enum :in_app_story_state_changes, { none: 0, relevant: 1, all: 2 }, prefix: :in_app_story_state
  enum :in_app_blockers, { none: 0, followed_stories: 1, all: 2 }, prefix: :in_app_blockers
  enum :in_app_comment_reactions, { no: 0, yes: 1 }, prefix: :in_app_comment_reactions
  enum :in_app_reviews, { no: 0, yes: 1 }, prefix: :in_app_reviews

  # Email notification enums
  enum :email_story_creation, { no: 0, yes: 1 }, prefix: :email_story_creation
  enum :email_comments, { none: 0, mentions_only: 1, all: 2 }, prefix: :email_comments
  enum :email_comment_source, { all_sources: 0, exclude_commits: 1 }, prefix: :email_comment_source
  enum :email_story_state_changes, { none: 0, relevant: 1, all: 2 }, prefix: :email_story_state
  enum :email_blockers, { none: 0, followed_stories: 1, all: 2 }, prefix: :email_blockers
  enum :email_comment_reactions, { no: 0, yes: 1 }, prefix: :email_comment_reactions
  enum :email_reviews, { no: 0, yes: 1 }, prefix: :email_reviews

  enum :in_app_state, { disabled: 0, enabled: 1 }, prefix: true
  enum :email_state, { disabled: 0, enabled: 1 }, prefix: true

  validates :user_id, uniqueness: true

  def muted?
    mute_state == "muted"
  end

  def muted_except_mentions?
    mute_state == "muted_except_mentions"
  end
end
