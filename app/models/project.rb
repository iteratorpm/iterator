class Project < ApplicationRecord
  enum :iteration_start_day, {
    sunday: 0, monday: 1, tuesday: 2, wednesday: 3,
    thursday: 4, friday: 5, saturday: 6
  }

  enum :point_scale, {
    linear_0123: 0, fibonacci: 1, powers_of_2: 2, custom: 3
  }

  enum :velocity_strategy, {
    past_iters_1: 0,
    past_iters_2: 1,
    past_iters_3: 2,
    past_iters_4: 3
  }

  enum :priority_display_scope, {
    icebox_only: 0, all_panels: 1
  }

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :api_visible, -> { where(archived: false, allow_api_access: true) }

  belongs_to :organization, counter_cache: true
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships
  has_many :integrations, dependent: :destroy
  has_many :epics, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :iterations, dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :description_templates, dependent: :destroy
  has_many :review_types, dependent: :destroy
  has_many :csv_exports, dependent: :destroy

  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user

  validates :organization, presence: true
  validates :name, length: { minimum: 1, maximum: 50 }
  validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  validates :velocity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false# In your Project model
  validates :point_scale_custom, presence: true, if: -> { point_scale == 'custom' }

  after_update :recalculate_if_velocity_settings_changed
  before_save :disable_public_if_archived

  def plan_current_iteration
    Time.use_zone(time_zone) do
      # Complete past iterations
      iterations.where("end_date <= ?", Time.zone.today).each(&:complete!)

      # Find or create current iteration
      current_iteration = find_or_create_current_iteration

      recalculate_iterations

      current_iteration
    end
  end

  def releases
    stories.releases
  end

  def user_ids
    users.pluck(:id)
  end

  # Helper methods for common role checks
  def owner?(user)
    project_memberships.exists?(user: user, role: :owner)
  end

  def member?(user)
    project_memberships.exists?(user: user)
  end

  def viewer?(user)
    project_memberships.exists?(user: user, role: :viewer)
  end

  # Add a user with a specific role
  def add_member(user, role = :member)
    project_memberships.create(user: user, role: role)
  end

  def current_iteration
    find_or_create_current_iteration
  end

  def find_or_create_current_iteration
    IterationPlanner.find_or_create_current_iteration(self)
  end

  def calculated_velocity
    IterationPlanner.calculate_project_velocity(self)
  end

  def recalculate_iterations
    IterationPlanner.recalculate_all_iterations(self)
  end

  def current_iteration_points
    find_or_create_current_iteration&.points_accepted || 0
  end

  def last_5_iterations
    iterations.done.order(start_date: :desc).limit(5)
  end

  def current_scope
    0
  end

  def current_iteration_cycle_time
    0
    # find_or_create_current_iteration&.average_cycle_time || 0
  end

  def average_cycle_time(iteration_count)
    0
    # iterations.completed.order(start_date: :desc).limit(iteration_count).average(:average_cycle_time) || 0
  end

  def current_iteration_rejection_rate
    find_or_create_current_iteration&.rejection_rate || 0
  end

  def average_rejection_rate(iteration_count)
    0
    # iterations.completed.order(start_date: :desc).limit(iteration_count).average(:rejection_rate) || 0
  end

  def calculate_velocity_data
    iterations = last_5_iterations
    {
      current_points: current_iteration_points,
      average_velocity: average_velocity(5),
      iterations: iterations.map do |iter|
        {
          date: iter.start_date.strftime("%b %d"),
          points: iter.points_completed,
          velocity: iter.velocity
        }
      end
    }
  end

  def calculate_stories_data
    iterations = last_5_iterations
    {
      total: stories.accepted.count,
      by_type: {
        "Feature" => stories.features.accepted.count,
        "Bug" => stories.bugs.accepted.count,
        "Chore" => stories.chores.accepted.count
      },
      iterations: iterations.map do |iter|
        {
          date: iter.start_date.strftime("%b %d"),
          features: iter.stories.features.accepted.count,
          bugs: iter.stories.bugs.accepted.count,
          chores: iter.stories.chores.accepted.count
        }
      end
    }
  end

  def average_velocity limit=5
    iterations.done.order(state_date: :desc).limit(limit).average(:points_completed)&.round(1) || 0
  end

  def volatility
    return "0%" if iterations.done.count < 2

    velocities = iterations.done.order(:start_date).pluck(:points_completed)
    average = velocities.sum.to_f / velocities.size
    deviations = velocities.map { |v| (v - average).abs }
    mean_deviation = deviations.sum.to_f / deviations.size

    return "0%" if average.zero?

    "#{((mean_deviation / average) * 100).round}%"
  end

  def muted_by?(user)
    user.muted_projects.exists?(id)
  end

  private

  def disable_public_if_archived
    self.public = false if archived_changed?(from: false, to: true)
  end

  def recalculate_if_velocity_settings_changed
    if saved_change_to_velocity_strategy? ||
        saved_change_to_iteration_length? ||
        saved_change_to_iteration_start_day?
      recalculate_iterations
    end
  end
end
