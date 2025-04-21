class Project < ApplicationRecord
  enum :iteration_start_day, {
    sunday: 0, monday: 1, tuesday: 2, wednesday: 3,
    thursday: 4, friday: 5, saturday: 6
  }

  enum :time_zone, {
    eastern: 0, central: 1, mountain: 2, pacific: 3
    # ...expand as needed
  }

  enum :point_scale, {
    linear_0123: 0, fibonacci: 1, tshirt_sizes: 2, powers_of_2: 3, custom: 4
  }

  enum :velocity_scheme, {
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
  has_many :iterations, dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :description_templates, dependent: :destroy
  has_many :review_types, dependent: :destroy
  has_many :csv_exports, dependent: :destroy

  validates :organization, presence: true

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

  def current_iteration
    iterations.current.first
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
end
