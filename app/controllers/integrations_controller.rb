class IntegrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  load_and_authorize_resource :organization

  def index
    @integrations = @organization.integrations.includes(:creator, :projects)
    @available_organizations = current_user.project_creator_organizations
  end

  def new
    @integration = @organization.integrations.new
    @providers = Integration.integration_types.keys.map(&:to_sym)
  end

  def create
    @integration = @organization.integrations.new(integration_params)
    @integration.creator = current_user

    if @integration.save
      redirect_to organization_integrations_path(@organization),
                  notice: 'Integration was successfully created.'
    else
      render :new
    end
  end

  def edit
    @integration = @organization.integrations.find(params[:id])
  end

  def update
    @integration = @organization.integrations.find(params[:id])
    if @integration.update(integration_params)
      redirect_to organization_integrations_path(@organization),
                  notice: 'Integration was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @integration = @organization.integrations.find(params[:id])
    @integration.destroy
    redirect_to organization_integrations_path(@organization),
                notice: 'Integration was successfully removed.'
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
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
      :active,
      project_ids: []
    )
  end
end
