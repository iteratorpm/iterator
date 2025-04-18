class Organization < ApplicationRecord
  enum :plan_type, {
    free: 0, pro: 1
  }

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :projects, dependent: :destroy
  has_many :integrations, through: :projects

  validates :name, length: { minimum: 1, maximum: 50 }

  # Returns the owner membership
  def owner_membership
    memberships.find_by(role: :owner)
  end

  # Returns the owner user
  def owner
    owner_membership&.user
  end

  # Transfer ownership to another member
  def transfer_ownership(new_owner_membership)
    return unless new_owner_membership.organization == self

    Membership.transaction do
      current_owner = owner_membership
      current_owner.update!(role: :admin) if current_owner
      new_owner_membership.update!(role: :owner)
    end
  end
end
