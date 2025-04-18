class ProjectIntegrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:index, :new, :create]
  load_and_authorize_resource :project

  def index
    @integrations = @project.integrations.includes(:creator, :provider)
  end

  def new
    @integration = @project.integrations.new
    @providers = Integration.integration_types.keys.map(&:to_sym)
  end

  def create
    @integration = @project.integrations.new(integration_params)
    @integration.creator = current_user

    if @integration.save
      redirect_to project_integrations_path(@project), notice: 'Integration was successfully created.'
    else
      render :new
    end
  end

  def edit
    @integration = Integration.find(params[:id])
  end

  def update
    @integration = Integration.find(params[:id])
    if @integration.update(integration_params)
      redirect_to project_integrations_path(@integration.project), notice: 'Integration was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @integration = Integration.find(params[:id])
    project = @integration.project
    @integration.destroy
    redirect_to project_integrations_path(project), notice: 'Integration was successfully removed.'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def integration_params
    params.require(:integration).permit(
      :name,
      :integration_type,
      :webhook_url,
      :api_key,
      :secret_token,
      :base_url,
      :username,
      :project_id,
      :active
    )
  end
end
