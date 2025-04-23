class Project < ApplicationRecord
  enum :iteration_start_day, {
    sunday: 0, monday: 1, tuesday: 2, wednesday: 3,
    thursday: 4, friday: 5, saturday: 6
  }

  enum :point_scale, {
    linear_0123: 0, fibonacci: 1, tshirt_sizes: 2, powers_of_2: 3, custom: 4
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

  belongs_to :organization
  has_many :memberships, class_name: "ProjectMembership", dependent: :destroy
  has_many :users, through: :memberships
  has_many :integrations, dependent: :destroy
  has_many :epics, dependent: :destroy
  has_many :iterations, dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :description_templates, dependent: :destroy
  has_many :review_types, dependent: :destroy
  has_many :csv_exports, dependent: :destroy

  validates :organization, presence: true
  validates :name, length: { minimum: 1, maximum: 50 }
  validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  validates :velocity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false

  before_validation :set_velocity, if: -> { velocity.nil? || velocity.zero? }

  def releases
    stories.releases
  end

  def user_ids
    users.pluck(:id)
  end

  # Helper methods for common role checks
  def owner?(user)
    memberships.exists?(user: user, role: :owner)
  end

  def member?(user)
    memberships.exists?(user: user)
  end

  def viewer?(user)
    memberships.exists?(user: user, role: :viewer)
  end

  # Add a user with a specific role
  def add_member(user, role = :member)
    memberships.create(user: user, role: role)
  end

  def find_or_create_current_iteration
    Iteration.find_or_create_current_iteration(self)
  end

  def create_current_iteration
    Time.use_zone(time_zone) do
      # Determine the correct start date based on project settings
      start_date = calculate_iteration_start_date
      end_date = start_date + (iteration_length || 1).weeks - 1.day

      # Get the next iteration number
      last_number = iterations.maximum(:number) || 0
      new_number = last_number + 1

      # Create and return the new iteration
      iterations.create!(
        start_date: start_date,
        end_date: end_date,
        number: new_number,
        current: true,
        velocity: velocity || initial_velocity
      ).tap do |iteration|
        # Ensure only one current iteration exists
        iterations.where.not(id: iteration.id).update_all(current: false)
      end
    end
  end

  # Recalculates all future iterations based on current velocity
  def recalculate_iterations
    return unless automatic_planning?

    current_iteration = iterations.current.first
    return unless current_iteration

    # Get all unstarted stories not in current iteration
    remaining_stories = stories.unstarted.where.not(iteration: current_iteration).ranked

    # Clear all future iterations
    iterations.backlog.destroy_all

    # Create new iterations and assign stories
    iteration = current_iteration
    while remaining_stories.any?
      iteration = iterations.create(
        start_date: iteration.end_date + 1.day,
        end_date: iteration.end_date + (iteration_length || 1).weeks
      )

      # Fill the iteration with stories up to velocity
      points_remaining = velocity || initial_velocity

      remaining_stories.each do |story|
        break if points_remaining <= 0

        if story.estimate && story.estimate <= points_remaining
          story.update(iteration: iteration)
          points_remaining -= story.estimate
        elsif story.unestimated?
          story.update(iteration: iteration)
        end
      end

      remaining_stories = stories.unstarted.where.not(iteration: [current_iteration, iteration]).ranked
    end
  end

  def current_iteration_points
    current_iteration&.points_accepted || 0
  end

  def average_velocity(iteration_count)
    0
    # iterations.completed.order(start_date: :desc).limit(iteration_count).average(:velocity) || 0
  end

  def last_5_iterations
    iterations.completed.order(start_date: :desc).limit(5)
  end

  def current_scope
    0
  end

  def current_iteration_cycle_time
    0
    # current_iteration&.average_cycle_time || 0
  end

  def average_cycle_time(iteration_count)
    0
    # iterations.completed.order(start_date: :desc).limit(iteration_count).average(:average_cycle_time) || 0
  end

  def current_iteration_rejection_rate
    current_iteration&.rejection_rate || 0
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
          points: iter.points_accepted,
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

  def calculate_iteration_start_date
    Time.use_zone(time_zone) do
      now = Time.zone.today
      preferred_wday = iteration_start_day_before_type_cast.to_i

      # Calculate days since last preferred weekday (including today if it matches)
      days_since_start_day = (now.wday - preferred_wday) % 7

      # Subtract to get to the most recent preferred weekday
      now - days_since_start_day
    end
  end

  private
  def set_velocity
    self.velocity = initial_velocity || 10
  end
end
