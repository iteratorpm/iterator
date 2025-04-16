class NotificationSetting < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true # nil means global settings

  enum :story_creation, { no: 0, yes: 1 }, _prefix: :story_creation
  enum :comments, { none: 0, mentions_only: 1, all: 2 }, _prefix: :comments
  enum :comment_source, { all_sources: 0, exclude_commits: 1 }, _prefix: :comment_source
  enum :story_state_changes, { none: 0, relevant: 1, all: 2 }, _prefix: :story_state
  enum :blockers, { none: 0, followed_stories: 1, all: 2 }, _prefix: :blockers
  enum :comment_reactions, { no: 0, yes: 1 }, _prefix: :comment_reactions
  enum :reviews, { no: 0, yes: 1 }, _prefix: :reviews

  enum :in_app_status, { disabled: 0, enabled: 1 }
  enum :email_status, { disabled: 0, enabled: 1 }

  # For muted projects
  enum :mute_status, { not_muted: 0, muted: 1, muted_except_mentions: 2 }
end
