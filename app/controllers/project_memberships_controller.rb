class ProjectMembershipsController < ApplicationController
  load_and_authorize_resource
  before_action :set_project
  before_action :set_membership, only: [:update, :destroy]

  def index
    @memberships = @project.memberships.includes(:user)
  end

  def new
    @membership = ProjectMembership.new
  end

  def search_users
    @q = User.ransack(name_or_email_cont: params[:term])
    @users = @q.result.where.not(id: @project.user_ids).limit(10)
    render json: @users
  end

  def create
    emails = membership_params[:emails].split(/[\s,]+/).reject(&:blank?)

    @memberships = emails.map do |email|
      user = User.find_or_invite_by_email(email)
      @project.memberships.create(user: user, role: :member)
    end

    if @memberships.all?(&:persisted?)
      redirect_to project_memberships_path(@project), notice: 'Invitations sent successfully.'
    else
      render :index
    end
  end

  def update
    if @membership.update(membership_params)
      redirect_to project_memberships_path(@project), notice: 'Role updated successfully.'
    else
      render :index
    end
  end

  def destroy
    @membership.destroy
    redirect_to project_memberships_path(@project), notice: 'Member removed successfully.'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_membership
    @membership = @project.memberships.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:emails, :role)
  end
end
