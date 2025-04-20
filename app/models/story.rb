class Story < ApplicationRecord
 include Discard::Model

  # Enums
  enum :story_type, { feature: 0, bug: 1, chore: 2, release: 3 }
  enum :status, { unstarted: 0, started: 1, finished: 2, delivered: 3, accepted: 4, rejected: 5 }
  enum :priority, { p1_highest: 0, p2_high: 1, p3_medium: 2, p4_low: 3 }

  # Associations
  belongs_to :project
  belongs_to :requester, class_name: 'User'
  belongs_to :epic, optional: true
  belongs_to :iteration, optional: true

  has_many :story_owners, dependent: :destroy
  has_many :owners, through: :story_owners, source: :user

  has_many :tasks, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :story_labels, dependent: :destroy
  has_many :labels, through: :story_labels
  has_many :blockers, dependent: :destroy
  has_many :followers, class_name: 'StoryFollower', dependent: :destroy
  has_many :reviews, dependent: :destroy

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :story_type, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :project, presence: true
  validates :requester, presence: true

  # Scopes for common queries (performance optimization)
  scope :by_status, ->(status) { where(status: status) }
  scope :by_story_type, ->(type) { where(story_type: type) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_owner, ->(user_id) { joins(:story_owners).where(story_owners: { user_id: user_id }) }
  scope :by_label, ->(label_id) { joins(:story_labels).where(story_labels: { label_id: label_id }) }

  after_update :notify_if_delivered, if: :saved_change_to_state?

  # Methods
  def add_owner(user)
    owners << user unless owners.include?(user)
  end

  def remove_owner(user)
    owners.delete(user)
  end

  def add_follower(user)
    followers.create(user: user) unless followers.exists?(user_id: user.id)
  end

  def total_tasks
    tasks.count
  end

  def completed_tasks
    tasks.where(completed: true).count
  end

  private
  def notify_if_delivered
    if delivered? && status_before_last_save != 'delivered'
      # Notify requester
      if requester && requester != user
        NotificationService.notify(requester, :story_delivered, self)
      end

      # Notify owner
      if owner && owner != user
        NotificationService.notify(owner, :story_delivered, self)
      end
    end
  end
end
