class Project < ApplicationRecord
  enum :iteration_start_day, {
    sunday: 0, monday: 1, tuesday: 2, wednesday: 3,
    thursday: 4, friday: 5, saturday: 6
  }

  enum :project_time_zone, {
    eastern: 0, central: 1, mountain: 2, pacific: 3
    # ...expand as needed
  }

  enum :point_scale, {
    linear_0123: 0, fibonacci: 1, tshirt_sizes: 2, powers_of_2: 3, custom: 4
  }

  enum :velocity_strategy, {
    average_3: 0, last_iteration: 1
  }

  enum :priority_display_scope, {
    icebox_only: 0, all_panels: 1
  }

  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user

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
end
