class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  def self.ransackable_attributes(auth_object = nil)
    %w[]
  end

  def self.ransackable_associations(auth_object = nil)
    [:user]
  end

  enum :role, {
    member: 0,        # Regular member
    project_creator: 1, # Can create projects
    admin: 2,         # Account admin
    owner: 3          # Account owner
  }, validate: true

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :organization_id }
  validate :single_owner_per_organization

  private

  def single_owner_per_organization
    if role_changed?(to: 'owner') && organization.memberships.where(role: :owner).exists?
      errors.add(:role, "can only have one owner per organization")
    end
  end

end
