class NotificationSetting < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true # nil means global settings

  enum :story_creation, { no: 0, yes: 1 }, prefix: :story_creation
  enum :comments, { none: 0, mentions_only: 1, all: 2 }, prefix: :comments
  enum :comment_source, { all_sources: 0, exclude_commits: 1 }, prefix: :comment_source
  enum :story_state_changes, { none: 0, relevant: 1, all: 2 }, prefix: :story_state
  enum :blockers, { none: 0, followed_stories: 1, all: 2 }, prefix: :blockers
  enum :comment_reactions, { no: 0, yes: 1 }, prefix: :comment_reactions
  enum :reviews, { no: 0, yes: 1 }, prefix: :reviews

  enum :in_app_state, { disabled: 0, enabled: 1 }, prefix: :in_app_state
  enum :email_state, { disabled: 0, enabled: 1 }, prefix: :email_state

  # Muting settings: 0 = not muted, 1 = muted, 2 = muted_except_mentions
  enum :mute_state, { not_muted: 0, muted: 1, muted_except_mentions: 2 }

  # === Convenience Predicate Methods ===

  def muted?
    mute_state == "muted"
  end

  def muted_except_mentions?
    mute_state == "muted_except_mentions"
  end
end
