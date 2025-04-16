class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  # GET /organizations
  def index
    @organizations = current_user.organizations.order(:name)

    respond_to do |format|
      format.html
      format.json { render json: @organizations }
    end
  end

  def show
    render json: @organization
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit
  end

  # POST /organizations
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        # Add current user as owner
        current_user.add_to_organization(@organization, :owner)

        # Set as default organization if user doesn't have one
        current_user.update(current_organization_id: @organization.id) unless current_user.current_organization_id

        format.html { redirect_to projects_path, notice: 'Organization was successfully created.' }
        format.json { render json: @organization, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @organization.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { render json: @organization }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @organization.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  def destroy
    # Don't allow deletion if it's the user's default organization
    if @organization.id == current_user.current_organization_id
      respond_to do |format|
        format.html { redirect_to organizations_url, alert: 'Cannot delete your default organization. Please set another organization as default first.' }
        format.json { render json: { error: 'Cannot delete default organization' }, status: :unprocessable_entity }
      end
      return
    end

    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url, notice: 'Organization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /organizations/set_default
  def set_default
    @organization = current_user.organizations.find(params[:organization_id])

    if current_user.update(current_organization_id: @organization.id)
      respond_to do |format|
        format.html { redirect_back fallback_location: organizations_path, notice: 'Default organization updated.' }
        format.json { render json: { message: 'Default organization updated' } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: organizations_path, alert: 'Failed to update default organization.' }
        format.json { render json: { error: 'Failed to update default organization' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_organization
    @organization = current_user.organizations.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :description)
  end
end
