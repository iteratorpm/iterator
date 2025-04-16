class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true
  belongs_to :notifiable, polymorphic: true

  enum :notification_type, {
    story_created: 0,
    story_delivered: 1,
    story_accepted: 2,
    story_rejected: 3,
    story_assigned: 4,
    comment_created: 5,
    mention_in_comment: 6,
    blocker_added: 7,
    blocker_resolved: 8,
    story_blocking: 9,
    comment_reaction: 10,
    review_assigned: 11,
    review_delivered: 12
  }

  enum :delivery_method, { in_app: 0, email: 1, both: 2 }

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { where('created_at >= ?', 10.days.ago) }
  scope :for_project, ->(project_id) { where(project_id: project_id) }
  scope :with_mentions, -> { where(notification_type: :mention_in_comment) }

  def mark_as_read
    update(read_at: Time.current)
  end
end
