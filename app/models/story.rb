class Story < ApplicationRecord
  include Discard::Model
  has_paper_trail

  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller&.current_user },
    recipient: ->(controller, model) { model.project },
    parameters: {
      changes: :tracked_changes,
      name: :name
    }

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
    accepted: 5,     # Current / Done
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

  # validate :cannot_move_unestimated_feature_to_current_iteration
  validate :cannot_start_unestimated_feature
  validate :state_must_be_valid_for_story_type
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

  attr_accessor :owner_ids_before_update

  after_update :notify_if_delivered, if: :saved_change_to_state?
  before_update :track_state_changes
  before_update :unscheduled_remove_iteration
  before_create :set_project_story_id

  def available_states
    case story_type.to_sym
    when :feature, :bug
      %i[unscheduled unstarted started finished delivered accepted rejected]
    when :chore
      %i[unscheduled unstarted started finished accepted rejected] # No :delivered
    when :release
      %i[unscheduled unstarted started accepted] # No :finished/:delivered/:rejected
    else
      []
    end
  end

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
    estimate.present? && estimate != -1
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

  def iteration_recalculation_needed?
    saved_change_to_estimate? ||
    saved_change_to_iteration_id? ||
    saved_change_to_state? ||
    saved_change_to_story_type?
  end

  # Efficiently determine which column(s) this story should appear in
  # Pass user_id explicitly since models shouldn't access current user directly
  def current_columns(user_id = nil)
    columns = []

    # Check if story is owned by the specified user for "My Work"
    if user_id && owner_ids.include?(user_id)
      columns << :my_work
    end

    # Determine primary column based on state and iteration
    case state.to_sym
    when :unscheduled
      columns << :icebox
    when :unstarted
      if iteration&.backlog?
        columns << :backlog
      elsif iteration&.current?
        columns << :current
      end
    when :started, :finished, :delivered, :rejected
      columns << :current
    when :accepted
      if iteration&.current?
        columns << :current
      elsif iteration&.done?
        columns << :done
      end
    end

    columns.uniq
  end

  def previous_columns_from_changes(changes_hash, user_id = nil)
    return [] if changes_hash.empty?

    # Create a snapshot with previous values
    prev_story = self.dup
    changes_hash.each do |attr, (old_val, _new_val)|
      prev_story.send("#{attr}=", old_val)
    end

    # Handle iteration changes specially
    if changes_hash.key?('iteration_id')
      old_iteration_id = changes_hash['iteration_id'][0]
      prev_story.iteration = old_iteration_id ? Iteration.find(old_iteration_id) : nil
    end

    prev_story.current_columns(user_id)
  end

  def current_columns_for_all_users
    # Get all users who might be affected (owners + project members)
    relevant_user_ids = (owner_ids + project.project_membership_ids).uniq

    # Build a hash of user_id => columns for detailed broadcasting
    columns_by_user = {}

    # Get columns for each relevant user (includes :my_work if they're an owner)
    relevant_user_ids.each do |user_id|
      user_columns = current_columns(user_id)
      columns_by_user[user_id] = user_columns if user_columns.any?
    end

    # Also include general columns (non-user-specific) under a nil key
    general_columns = current_columns(nil)
    columns_by_user[nil] = general_columns if general_columns.any?

    columns_by_user
  end

  # Helper method to get all unique columns this story appears in
  def all_current_columns
    # Get all users who might be affected (owners + project members)
    relevant_user_ids = (owner_ids + project.member_ids).uniq

    all_columns = Set.new

    # Get columns for each relevant user (includes :my_work if they're an owner)
    relevant_user_ids.each do |user_id|
      all_columns.merge(current_columns(user_id))
    end

    # Also include general columns (non-user-specific)
    all_columns.merge(current_columns(nil))

    all_columns.to_a
  end

  def available_next_states
    case story_type.to_sym
    when :feature, :bug
      case state.to_sym
      when :unscheduled, :unstarted then [:started]
      when :started                then [:finished]
      when :finished               then [:delivered]
      when :delivered              then [:accepted, :rejected]
      when :rejected               then [:restarted] # Maps to :started
      else []
      end
    when :chore
      case state.to_sym
      when :unscheduled, :unstarted then [:started]
      when :started                then [:finished]
      when :finished               then [:accepted, :rejected] # No :delivered
      when :rejected               then [:restarted]
      else []
      end
    when :release
      case state.to_sym
      when :unscheduled, :unstarted            then [:started]
      when :started                then [:accepted] # Skip :finished/:delivered
      else []
      end
    else
      []
    end
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

  def trigger_iteration_recalculation
    project.recalculate_iterations
  end

  def unscheduled_remove_iteration
    return unless state_changed?

    if unscheduled?
      self.iteration = nil
    end
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

  # Get previous columns before changes (for cleanup)
  def previous_columns(user_id = nil)
    return [] unless saved_changes.any?

    # Create a temporary story object with previous attributes
    prev_story = self.dup
    saved_changes.each do |attr, (old_val, _new_val)|
      prev_story.send("#{attr}=", old_val)
    end

    # Handle iteration changes specially since it's an association
    if saved_changes.key?('iteration_id')
      old_iteration_id = saved_changes['iteration_id'][0]
      prev_story.iteration = old_iteration_id ? Iteration.find(old_iteration_id) : nil
    end

    prev_story.current_columns(user_id)
  end

  def cannot_start_unestimated_feature
    return unless will_save_change_to_state?
    return unless feature? && !estimated?

    if !%i[unscheduled unstarted].include?(state.to_sym)
      errors.add(:base, "Feature must be estimated before starting")
    end
  end

  def cannot_move_unestimated_feature_to_current_iteration
    if feature? && !estimated? && iteration&.current?
      errors.add(:base, "Feature must be estimated before moving to the current iteration")
    end
  end

  def state_must_be_valid_for_story_type
    return if available_states.include?(state.to_sym)
    errors.add(:state, "is not valid for story type #{story_type}")
  end
end
