class Story < ApplicationRecord
  include Discard::Model
  has_paper_trail

  # Enums
  enum :story_type, { feature: 0, bug: 1, chore: 2, release: 3 }
  enum :state, {
    unscheduled: 0,  # Icebox
    unstarted: 1,    # Backlog
    started: 2,      # Current
    finished: 3,     # Current
    delivered: 4,    # Current
    accepted: 5,     # Done
    rejected: 6      # Current
  }
  enum :priority, { none: 0, critical: 1, high: 2, medium: 3, low: 4 }, prefix: :priority

  # Associations
  belongs_to :project, counter_cache: true
  belongs_to :requester, class_name: 'User'
  belongs_to :epic, optional: true
  belongs_to :iteration, optional: true

  has_many :story_owners, dependent: :destroy
  has_many :owners, through: :story_owners, source: :user

  has_many :tasks, dependent: :destroy
  has_many :story_labels, dependent: :destroy
  has_many :labels, through: :story_labels
  has_many :blockers, dependent: :destroy
  has_many :blocking_stories, class_name: "Blocker", foreign_key: "blocker_story_id"
  has_many :followers, class_name: 'StoryFollower', dependent: :destroy
  has_many :reviews, dependent: :destroy

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  positioned on: :project

  # Validations
  validates :name, presence: true
  validates :story_type, presence: true
  validates :state, presence: true
  validates :priority, presence: true
  validates :project, presence: true
  validates :requester, presence: true

  validates :project_story_id, uniqueness: { scope: :project_id }

  # Scopes for common queries (performance optimization)
  scope :by_state, ->(state) { where(state: state) }
  scope :by_story_type, ->(type) { where(story_type: type) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_owner, ->(user_id) { joins(:story_owners).where(story_owners: { user_id: user_id }) }
  scope :by_label, ->(label_id) { joins(:story_labels).where(story_labels: { label_id: label_id }) }

  scope :releases, -> { where(story_type: :release) }
  scope :features, -> { where(story_type: :feature) }
  scope :bugs, -> { where(story_type: :bug) }
  scope :chores, -> { where(story_type: :chore) }
  scope :accepted, -> { where(state: :accepted) }
  scope :created_in_current_iteration, ->(project) {
    where(created_at: project.current_iteration.start_date..project.current_iteration.end_date)
  }

  scope :done, -> { where(state: :accepted) }
  scope :backlog, -> { where(state: :unstarted) }
  scope :icebox, -> { where(state: :unscheduled) }
  scope :current, -> { where(state: [:started, :finished, :delivered, :rejected]) }

  scope :unstarted, -> { where(state: :unstarted) }
  scope :started, -> { where(state: :started) }
  scope :rejected, -> { where(state: :rejected) }
  scope :accepted, -> { where(state: :accepted) }
  scope :estimated, -> { where.not(estimate: nil) }
  scope :unestimated, -> { where(estimate: nil) }
  scope :ranked, -> { order(position: :asc) }

  after_update :notify_if_delivered, if: :saved_change_to_state?
  before_create :set_project_story_id

  def done?
    accepted?
  end

  def backlog?
    unstarted?
  end

  def icebox?
    unscheduled?
  end

  def current?
    started? || finished? || delivered? || rejected?
  end

  def estimated?
    estimate.present?
  end

  def estimatable?
    # Features are typically estimatable, bugs might be, chores usually aren't
    feature? || bug?
  end

  def unestimated?
    estimate.blank?
  end

  def has_blockers?
    blockers.any?
  end

  def priority_label
    case priority
    when "priority_critical"
      "P1 - Critical"
    when "priority_high"
      "P2 - High"
    when "priority_medium"
      "P3 - Medium"
    when "priority_low"
      "P4 - Low"
    else
      "Unprioritized"
    end
  end

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

  def cycle_time
    # Calculate cycle time in hours
    return 0 unless finished_at && started_at
    ((finished_at - started_at) / 1.hour).round
  end

  def time_in_state(state)
    # Calculate time spent in a particular state
  end

  private
  def notify_if_delivered
    if delivered? && state_before_last_save != 'delivered'
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

  def set_project_story_id
    max_id = project.stories_count
    self.project_story_id = max_id + 1
  end
end
