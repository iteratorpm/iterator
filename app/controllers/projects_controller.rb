class ProjectsController < ApplicationController
  load_and_authorize_resource except: [:new, :create, :index]
  before_action :authenticate_user!, only: [:index]

  def index
    @active_projects = current_user.projects.active
    @archived_projects = current_user.projects.archived
    @favorite_projects = current_user.favorite_projects
  end

  def new
    @project = Project.new(
      iteration_start_day: :monday,
      time_zone: "Eastern Time (US & Canada)",
      point_scale: 0,
      velocity_strategy: 2,
      initial_velocity: 10,
      iteration_length: 2,
      done_iterations_to_show: 4,
      organization_id: params[:organization_id] || current_user.current_organization_id
    )

    authorize! :new, @project

    @organizations = current_user.organizations.order(:name)
  end

  def create
    @project = Project.new project_params

    authorize! :create, @project

    if @project.save
      # Add current user as owner
      @project.project_memberships.create(user: current_user, role: :owner)

      redirect_to @project, notice: 'Project was successfully created.'
    else
      @organizations = current_user.organizations.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def archive
    if @project.update(archived: true)
      redirect_to edit_project_path(@project), notice: 'Project was successfully archived.'
    else
      @organizations = current_user.organizations
      render :edit, status: :unprocessable_entity
    end
  end

  def unarchive
    if @project.update(archived: false)
      redirect_to edit_project_path(@project), notice: 'Project was successfully unarchived.'
    else
      @organizations = current_user.organizations
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @active_panel = cookies[:active_panel] || "current_#{@project.id}"

    @my_work_count = if signed_in?
                       @project.stories.by_owner(current_user.id).count
                     else
                       0
                     end

    @blocked_count = @project.stories.blocked.count
  end

  def edit
    @organizations = current_user.organizations
  end

  def update
    if @project.update(project_params)
      redirect_to edit_project_path(@project), notice: 'Project was successfully updated.'
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
      :name,
      :description,
      :organization_id,
      :enable_tasks,
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
      :automatic_planning,
      :allow_api_access,
      :enable_incoming_emails,
      :hide_email_addresses,
      :priority_field_enabled,
      :priority_display_scope,
      :point_bugs_and_chores
    )
  end

end
