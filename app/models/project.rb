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
  has_many :webhooks, dependent: :destroy

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
end
