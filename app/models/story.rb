class Story < ApplicationRecord
  include Discard::Model
  has_paper_trail

  def self.ransackable_attributes(auth_object = nil)
    # Whitelist only the attributes you want searchable
    %w[
      id
      name
      description
      story_type
      state
      estimate
      created_at
      updated_at
      accepted_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    # Whitelist associations that can be searched
    %w[
      owners
      requester
      labels
      comments
      tasks
      attachments
      blockers
    ]
  end

  # Enums
  enum :story_type, { feature: 0, bug: 1, chore: 2, release: 3 }
  enum :state, {
    unscheduled: 0,  # Icebox
    unstarted: 1,    # Backlog / Current
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

  validates :estimate, numericality: { greater_than_or_equal_to: -1 }, allow_nil: false

  validates :project_story_id, uniqueness: { scope: :project_id }

  # Scopes for common queries (performance optimization)
  scope :blocked, -> { joins(:blockers).distinct }
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
  scope :no_iteration, -> { where(iteration_id: nil) }

  scope :unaccepted, -> { where.not(state: :accepted) }
  scope :unstarted, -> { where(state: :unstarted) }
  scope :started, -> { where(state: :started) }
  scope :rejected, -> { where(state: :rejected) }
  scope :accepted, -> { where(state: :accepted) }
  scope :estimated, -> { where.not(estimate: -1) }
  scope :unestimated, -> { where(estimate: -1) }
  scope :ranked, -> { order(position: :asc) }

  after_update :notify_if_delivered, if: :saved_change_to_state?
  before_update :track_state_changes
  before_create :set_project_story_id
  after_commit :broadcast_story_update

  def done?
    accepted?
  end

  def backlog?
    unstarted? || iteration_id.present? && !iteration.current?
  end

  def icebox?
    unscheduled?
  end

  def current?
    started? || finished? || delivered? || rejected?
  end

  def estimated?
    estimate != -1
  end

  def estimatable?
    feature?
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

  attr_accessor :_user
  def update_with_user(params, user)
    self._user = user
    update(params)
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

  def current_panel
    return :icebox if unscheduled?
    return :backlog if unstarted?
    return :current if started? || finished? || delivered? || rejected?
    return :done if accepted?
  end

  def iteration_recalculation_needed?
    saved_change_to_estimate? ||
    saved_change_to_iteration_id? ||
    saved_change_to_state? ||
    saved_change_to_story_type?
  end

  private
  def notify_if_delivered
    if delivered? && state_before_last_save != 'accepted'
      # Notify requester
      if requester && !owners.include?(requester)
        NotificationService.notify(requester, :story_delivered, self)
      end

      # Notify owner
      owners.each do |owner|
        NotificationService.notify(owner, :story_delivered, self)
      end
    end
  end

  def set_project_story_id
    max_id = project.stories.maximum(:project_story_id) || 0
    self.project_story_id = max_id + 1
  end

  def broadcast_story_update
    panel = current_panel

    partial = if panel == :current
      "projects/iterations/column"
    else
      "projects/stories/column"
    end

    broadcast_replace_later_to(
      [project, "stories"],
      target: "column-#{panel}",
      partial: partial,
      locals: { project_id: project.id, state: state }
    )
  end

  def trigger_iteration_recalculation
    project.recalculate_iterations
  end

  def track_state_changes
    return unless state_changed?

    case state
    when "started"
      self.started_at ||= Time.current
      owners << _user if _user && !owners.include?(_user)
    when "accepted"
      self.accepted_at ||= Time.current
    when "rejected"
      self.rejected_at ||= Time.current
    end
  end
end
