class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest permissions (not logged in)
    can :read, Project, public: true

    return unless user.present?  # Additional permissions for logged in users

    # Users can manage projects they own
    can :manage, Project, project_memberships: { user_id: user.id, role: :owner }

    # Users can read and update projects where they're members
    can [:read, :update], Project, project_memberships: { user_id: user.id, role: :member }

    # Users can read projects where they're viewers
    can :read, Project, project_memberships: { user_id: user.id, role: :viewer }

    # Users can manage their own project memberships
    can :manage, ProjectMembership, project: { project_memberships: { user_id: user.id, role: :owner } }
    can [:read, :create], ProjectMembership, project: { project_memberships: { user_id: user.id, role: :member } }

    # Admin permissions (override everything)
    if user.admin?
      can :manage, :all
    end
  end
end
