class Projects::PanelsController < ApplicationController
  before_action :set_project
  before_action :set_panel_id
  before_action :authorize_project

  def done
    @iterations = @project.iterations.done.includes(:stories).order(start_date: :asc)
    render_panel
  end

  def current
    @current_iteration = @project.find_or_create_current_iteration
    render_panel
  end

  def current_backlog
    @current_iteration = @project.find_or_create_current_iteration
    @backlog_iterations = @project.iterations.backlog.includes(:stories)
    render_panel
  end

  def backlog
    @iterations = @project.iterations.backlog.includes(:stories)
    render_panel
  end

  def icebox
    @stories = @project.stories.icebox.ranked
    render_panel
  end

  def epics
    render_panel
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def authorize_project
    authorize! :read, @project
  end

  def render_panel
    respond_to do |format|
      format.html
      format.json { render json: panel_json }
    end
  end

  def panel_json
    {
      panel: @panel_id,
      stories: @stories&.as_json(include: [:owners, :iteration]),
      current_iteration: defined?(@current_iteration) ? @current_iteration.as_json : nil,
      iterations: defined?(@iterations) ? @iterations.as_json : nil
    }
  end

  def set_panel_id
    @panel_id = "#{action_name}_panel"
  end
end
