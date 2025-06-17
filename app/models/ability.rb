class Ability
  include CanCan::Ability

  def initialize(user)
    # Guest permissions
    can :read, Project, public: true

    return unless user.present?

    # Organization permissions
    can :read, Organization, memberships: { user_id: user.id }
    can :create, Organization

    can :manage, Organization, memberships: { user_id: user.id, role: :owner }
    can :plans_and_billing, Organization, memberships: { user_id: user.id, role: :owner }

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

    # Project permissions
    can :manage, Project, project_memberships: { user_id: user.id, role: :owner }
    can :read, Project, project_memberships: { user_id: user.id, role: [:viewer, :member] }

    # Organization owners/admins can manage any project within their org
    can :manage, Project do |project|
      org = project.organization
      org.present? && org.memberships.where(user_id: user.id, role: [:owner, :admin]).exists?
    end

    # Project membership management
    can :manage, ProjectMembership, project: { project_memberships: { user_id: user.id, role: :owner } }
    can :manage, ProjectMembership do |project_membership|
      project = project_membership.project
      project.organization.memberships.where(user_id: user.id, role: [:owner, :admin]).exists?
    end

    can :manage, Webhook, project: { project_memberships: { user_id: user.id, role: :owner } }

    # Stories
    can :read, Story, project: { project_memberships: { user_id: user.id, role: [:viewer, :member, :owner] } }
    can :manage, Story do |story|
      story.project.project_memberships.exists?(user: user, role: [:owner, :member])
    end

    can :read, Epic, project: { project_memberships: { user_id: user.id, role: [:viewer, :member, :owner] } }
    can :manage, Epic, project: { project_memberships: { user_id: user.id, role: [:owner, :member] } }

    can :read, Label, project: { project_memberships: { user_id: user.id, role: [:viewer, :member, :owner] } }
    can :manage, Label, project: { project_memberships: { user_id: user.id, role: [:owner, :member] } }

    # Comments
    can :create, Comment, project: { project_memberships: { user_id: user.id, role: [:owner, :member] } }
    can :edit, Comment, author_id: user.id
    can :destroy, Comment do |comment|
      comment.author_id == user.id || comment.project.project_memberships.where(user_id: user.id, role: :owner).exists?
    end

    # Attachments
    can [:create, :destroy], Attachment, project: { project_memberships: { user_id: user.id, role: [:owner, :member] } }

    # Follow / Notification access for viewers
    can :follow, Story, project: { project_memberships: { user_id: user.id, role: :viewer } }
    can :manage, Notification, user_id: user.id

    # Account-wide actions
    if user.memberships.where(role: [:owner, :admin]).exists?
      can :projects, Organization
      can :memberships, Organization
      can :project_report, Organization
    end
  end
end
