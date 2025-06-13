class ProjectMembershipsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :membership, through: :project, except: [:search_users]

  def index
    @memberships = @project.memberships.includes(:user)
  end

  def new
    @membership = ProjectMembership.new
  end

  def search_users
    organization_users = @project.organization.users

    @q = organization_users.ransack(name_or_email_cont: params[:term])

    @users = @q.result.where.not(id: @project.user_ids).limit(10)

    render json: @users.as_json(only: [:name, :email, :initials])
  end

  def create
    emails = membership_params[:emails].split(/[\s,]+/).reject(&:blank?)
    @memberships = []

    emails.each do |email|
      user = User.find_or_invite_by_email(email)
      if user
        membership = @project.memberships.build(user: user, role: :member)
        @memberships << membership if membership.save
      end
    end

    if @memberships.size == emails.size
      redirect_to project_memberships_path(@project), notice: 'Invitations sent successfully.'
    else
      @membership = ProjectMembership.new(emails: membership_params[:emails])
      flash.now[:alert] = 'Some invitations could not be sent.'
      render :new
    end
  end

  def update
    if @membership.update(membership_params)
      redirect_to project_memberships_path(@project), notice: 'Role updated successfully.'
    else
      flash.now[:alert] = @membership.errors.full_messages.to_sentence
      render :index
    end
  end

  def destroy
    @membership.destroy
    redirect_to project_memberships_path(@project), notice: 'Member removed successfully.'
  end

  private

  def membership_params
    params.require(:project_membership).permit(:emails, :role)
  end
end
