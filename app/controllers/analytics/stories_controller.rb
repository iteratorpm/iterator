class Analytics::StoriesController < ApplicationController
  before_action :set_project

  def index
    @iterations = @project.iterations.order(start_date: :desc)
    @selected_iteration = params[:iteration_id] ? @project.iterations.find(params[:iteration_id]) : @iterations.first

    versions = PaperTrail::Version.where(
      item_type: 'Story',
      item_id: @selected_iteration.stories.select(:id)
    ).order(created_at: :desc)

    @activities = versions.group_by { |v| v.created_at.to_date }

    @timezone = @project.time_zone || 'America/Chicago'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

end
