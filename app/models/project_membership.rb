class ProjectMembership < ApplicationRecord
  belongs_to :project
  belongs_to :user

  enum :role, {
    owner: 0,
    member: 1,
    viewer: 2
  }, default: :member

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :project_id }

  delegate :name, :email, to: :user, prefix: true
end
