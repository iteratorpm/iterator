class Projects::BaseController < ApplicationController
  before_action :set_project
  before_action :set_panel_id
  before_action :authorize_project

  private

  def set_project
    @project = Project.find(params[:project_id] || params[:id])
  end

  def set_panel_id
    @panel_id = "#{action_name}_panel"
  end

  def authorize_project
    authorize! :read, @project
  end
end
