class ProjectMembershipsController < ApplicationController
  load_and_authorize_resource :project, only: [:index, :new, :create, :search_users]
  load_and_authorize_resource :project_membership, through: :project,
                              shallow: true,
                              except: [:create]

  def index
    @memberships = @project.project_memberships.includes(:user)
  end

  def new
    @membership = @project.project_memberships.build
  end

  def search_users
    organization_users = @project.organization.users
    @q = organization_users.ransack(name_or_email_cont: params[:term])
    @users = @q.result.where.not(id: @project.user_ids).limit(10)
    render json: @users.as_json(only: [:name, :email, :initials])
  end

  def create
    authorize! :create, ProjectMembership.new(project: @project)

    emails = membership_params[:emails].split(/[\s,]+/).reject(&:blank?)
    role = membership_params[:role] || 'member'
    @memberships = []

    emails.each do |email|
      user = User.find_or_invite_by_email(email, current_user)
      if user
        membership = @project.project_memberships.build(user: user, role: role)
        @memberships << membership if membership.save
      end
    end

    if @memberships.size == emails.size
      redirect_to project_memberships_path(@project), notice: 'Invitations sent successfully.'
    else
      @membership = @project.project_memberships.build(emails: membership_params[:emails])
      flash.now[:alert] = 'Some invitations could not be sent.'
      render :new
    end
  end

  def resend_invitation
    project = @project_membership.project

    if @project_membership.user.invitation_pending?
      @project_membership.user.invite!
      redirect_to project_memberships_path(project), notice: 'Invitation resent successfully.'
    else
      redirect_to project_memberships_path(project), alert: 'User has already accepted the invitation.'
    end
  end

  def update
    project = @project_membership.project

    if @project_membership.update(membership_params)
      redirect_to project_memberships_path(project), notice: 'Role updated successfully.'
    else
      flash.now[:alert] = @project_membership.errors.full_messages.to_sentence
      render :index
    end
  end

  def destroy
    project = @project_membership.project
    @project_membership.destroy
    redirect_to project_memberships_path(project), notice: 'Member removed successfully.'
  end

  private

  def membership_params
    permitted_params = params.require(:project_membership).permit(:emails, :role)

    # Whitelist allowed roles based on user's permissions
    allowed_roles = determine_allowed_roles

    # Default to 'member' if role is not provided or not allowed
    if permitted_params[:role].present? && allowed_roles.include?(permitted_params[:role])
      permitted_params[:role] = permitted_params[:role]
    else
      permitted_params[:role] = 'member'
    end

    permitted_params
  end

  def determine_allowed_roles
    # Only allow basic roles by default
    allowed = ['member', 'viewer']

    # Check if current user can assign higher roles
    if can?(:manage, @project)
      # Project owners/admins can assign all roles except owner
      allowed += ['admin'] unless @project_membership&.role == 'owner'
    end

    # Only organization owners can assign project owner role
    if @project.present? && @project.organization.memberships.where(user_id: current_user.id, role: 'owner').exists?
      allowed << 'owner'
    end

    allowed
  end
end
