class ProjectsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!, only: [:index]

  def index
  end

  def new
    @project = Project.new(
      iteration_start_day: 0,
      time_zone: 0,
      point_scale: 0,
      velocity_strategy: 0,
      initial_velocity: 10,
      iteration_length: 1,
      done_iterations_to_show: 4,
      organization_id: params[:organization_id]
    )
    @organizations = current_user.organizations.order(:name)
  end

  def create
    @project.organization_id ||= current_user.current_organization_id

    if @project.save
      # Add current user as owner
      @project.project_memberships.create(user: current_user, role: :owner)

      redirect_to @project, notice: 'Project was successfully created.'
    else
      @organizations = current_user.organizations
      render :new, status: :unprocessable_entity
    end
  end

  def memberships
  end

  def archive
  end

  def show
  end

  def edit
    @organizations = current_user.organizations
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      @organizations = current_user.organizations
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully deleted.'
  end

  private

  def project_params
    params.require(:project).permit(
      :title,
      :description,
      :organization_id,
      :public,
      :iteration_start_day,
      :start_date,
      :time_zone,
      :iteration_length,
      :point_scale,
      :point_scale_custom,
      :initial_velocity,
      :velocity_strategy,
      :done_iterations_to_show,
      :auto_iteration_planning,
      :allow_api_access,
      :enable_incoming_emails,
      :hide_email_addresses,
      :priority_field_enabled,
      :priority_display_scope,
      :point_bugs_and_chores,
      :enable_tasks
    )
  end
end
