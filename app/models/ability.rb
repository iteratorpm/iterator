class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest permissions
    can :read, Project, public: true

    return unless user.present?

    # Organization permissions
    can :read, Organization, memberships: { user_id: user.id }

    can :manage, Organization, memberships: { user_id: user.id, role: :owner }
    can :manage_billing, Organization, memberships: { user_id: user.id, role: :owner }

    can [:read, :update, :transfer_ownership], Organization, memberships: { user_id: user.id, role: :admin }

    # Membership management
    can :manage, Membership, organization: { memberships: { user_id: user.id, role: [:owner, :admin] } }
    cannot :destroy, Membership, role: :owner
    cannot [:update, :destroy], Membership, user_id: user.id

    # Project creation
    can :new, Project
    can :new, Organization
    can :new, Membership
    can :new, ProjectMembership
    can :new, Integration
    can :new, Webhook

    can :manage, Integration, { user_id: user.id, role: :owner }

    # Project-level access
    can :create, Project, organization: { memberships: { user_id: user.id, role: [:owner, :project_creator, :admin] } }

    can :manage, Project, memberships: { user_id: user.id, role: :owner }
    can [:read, :update], Project, memberships: { user_id: user.id, role: :member }
    can :read, Project, memberships: { user_id: user.id, role: :viewer }

    # Organization owners/admins can manage any project within their org
    can [:read, :update, :manage], Project do |project|
      org = project.organization

      org.present? && org.memberships.where(user_id: user.id, role: [:owner, :admin]).exists?
    end

    # Project membership management
    can :manage, ProjectMembership, project: { memberships: { user_id: user.id, role: :owner } }
    can :manage, Webhook, project: { memberships: { user_id: user.id, role: :owner } }

    # Stories
    can [:create, :update, :move, :destroy], Story, project: { memberships: { user_id: user.id, role: [:owner, :member] } }
    can :read, Story, project: { memberships: { user_id: user.id, role: :viewer } }
    can :manage, Story, project: { memberships: { user_id: user.id, role: [:owner, :member] } }

    # Comments
    can [:create], Comment, project: { memberships: { user_id: user.id, role: [:owner, :member] } }
    can :edit, Comment, user_id: user.id
    can :destroy, Comment do |comment|
      comment.user_id == user.id || comment.project.memberships.where(user_id: user.id, role: :owner).exists?
    end

    # Attachments
    can [:create, :destroy], Attachment, project: { memberships: { user_id: user.id, role: [:owner, :member] } }

    # Follow / Notification access for viewers
    can :follow, Story, project: { memberships: { user_id: user.id, role: :viewer } }

    # Account-wide actions
    if user.memberships.where(role: [:owner, :admin]).exists?
      can :view_all_projects, Organization
      can :manage_account_members, Organization
    end
  end
end
