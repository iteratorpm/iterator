class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :project
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

  validates :project, presence: true
  validates :user, presence: true
  validates :notifiable, presence: true

  def mark_as_read
    update(read_at: Time.current)
  end

  def story_name
    case notifiable_type
    when "Story"
      notifiable&.name
    when "User"
      nil
    when "Comment"
      notifiable&.commentable&.name
    else
      notifiable&.story&.name
    end
  end

  def story_url
    story = case notifiable_type
    when "Story"
      notifiable
    when "User"
      nil
    when "Comment"
      notifiable&.commentable
    else
      notifiable&.story
    end

    story ? Rails.application.routes.url_helpers.project_story_path(story.project, story) : nil
  end
end
