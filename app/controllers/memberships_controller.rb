class MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  authorize_resource

  def index
    @q = @organization.memberships.ransack(user_username_or_user_name_or_user_email_cont: params[:q])
    @memberships = @q.result.includes(:user)

    apply_filters
  end

  def new
    @membership = @organization.memberships.build
  end

  def create
    user = User.find_by(email: membership_params[:email])

    if user
      # Existing user flow
      @membership = @organization.memberships.build(user: user)
      if @membership.update(membership_params.except(:email))
        redirect_to organization_memberships_path(@organization), notice: 'Member was successfully added.'
      else
        render :new, alert: @membership.errors.full_messages.join(', ')
      end
    else
      # New user flow - render form for additional details
      @email = membership_params[:email]
      render :new_user_form
    end
  end

  def create_with_new_user
    user = User.invite!({
      email: new_user_params[:email],
      name: new_user_params[:name],
      initials: new_user_params[:initials]
    }, current_user) do |u|
      u.skip_invitation = true
    end

    @membership = @organization.memberships.build(user: user, role: new_user_params[:role], project_creator: new_user_params[:project_creator])

    if @membership.save
      user.deliver_invitation
      redirect_to organization_memberships_path(@organization), notice: 'Invitation sent successfully.'
    else
      @email = new_user_params[:email]
      render :new_user_form, alert: @membership.errors.full_messages.join(', ')
    end
  end

  def edit
    @membership = @organization.memberships.find(params[:id])
  end

  def update
    @membership = @organization.memberships.find(params[:id])
    if @membership.update(membership_params.except(:email))
      redirect_to organization_memberships_path(@organization), notice: 'Member was successfully updated.'
    else
      render :edit, alert: @membership.errors.full_messages.join(', ')
    end
  end

  def destroy
    @membership = @organization.memberships.find(params[:id])
    @membership.destroy
    redirect_to organization_memberships_path(@organization), notice: 'Member was successfully removed.'
  end

  def report
    @memberships = @organization.memberships.includes(:user)
    respond_to do |format|
      format.csv { send_data generate_csv, filename: "memberships-#{Date.today}.csv" }
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def membership_params
    params.require(:membership).permit(:email, :role, :project_creator)
  end

  def new_user_params
    params.require(:membership).permit(:email, :name, :initials, :role, :project_creator)
  end

  def apply_filters
    case params[:filter]
    when 'admin'
      @memberships = @memberships.where(role: :admin)
    when 'project_creator'
      @memberships = @memberships.where(project_creator: true)
    end

    if params[:hide_non_collaborators] == '1'
      @memberships = @memberships.where.not(role: :member)
    end
  end

  def generate_csv
    CSV.generate(headers: true) do |csv|
      csv << ['Name', 'Email', 'Role', 'Project Creator', 'Joined At']
      @memberships.each do |m|
        csv << [m.user.name, m.user.email, m.role.humanize, m.project_creator, m.created_at.to_date]
      end
    end
  end
end
