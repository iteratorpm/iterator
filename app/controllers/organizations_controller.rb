class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json { render json: @organizations }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @organization }
    end
  end

  def plans_and_billing; end

  def projects
    @projects = params[:archived] == "true" ? @organization.projects.archived : @organization.projects.where(archived: false)
  end

  def memberships
    @memberships = @organization.memberships
  end

  def project_report
    respond_to do |format|
      format.json { render json: @organization }
      format.csv { render csv: @organization }
    end
  end

  def new; end

  def edit; end

  def create
    respond_to do |format|
      if @organization.save
        current_user.add_to_organization(@organization, :owner)
        current_user.update(current_organization_id: @organization.id) unless current_user.current_organization_id

        format.html { redirect_to projects_path, notice: 'Organization was successfully created.' }
        format.json { render json: @organization, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @organization.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

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

  def destroy
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

  private

  def organization_params
    params.require(:organization).permit(:name)
  end
end
