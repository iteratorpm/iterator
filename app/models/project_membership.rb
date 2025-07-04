class ProjectMembership < ApplicationRecord
  belongs_to :project, counter_cache: true
  belongs_to :user

  enum :role, {
    owner: 0,
    member: 1,
    viewer: 2
  }, default: :member

  scope :owners, -> { where(role: :owner) }
  scope :members, -> { where(role: :member) }
  scope :viewers, -> { where(role: :viewer) }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :project_id }

  delegate :name, :email, to: :user, prefix: true
end
