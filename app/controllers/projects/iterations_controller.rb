class Projects::IterationsController < ApplicationController

  before_action :set_project

  def update
    @iteration.update!(team_strength: params[:team_strength])
    @iteration.project.recalculate_velocity
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

end
