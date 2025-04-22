class Projects::PanelsController < ApplicationController
  before_action :set_project
  before_action :set_panel_data

  PANEL_TYPES = {
    'done' => { title: 'Done', render_iterations: true },
    'current' => { title: 'Current Iteration', render_iteration: true },
    'current_backblog' => { title: 'Current Iteration/Backlog', render_iteration: true },
    'backlog' => { title: 'Backlog', render_iteration: true },
    'icebox' => { title: 'Icebox' },
    'epics' => { title: 'Epics', render_epics: true }
  }.freeze

  def show
    respond_to do |format|
      format.html
      format.json { render json: panel_json }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_panel_data
    @panel_type = params[:panel]
    @panel_config = PANEL_TYPES.fetch(@panel_type)
    @stories = @project.stories.order(:position) if @panel_type != 'epics'
    # @stories = @project.stories.send(@panel_type).order(:position) if @panel_type != 'epics'
  end

  def panel_json
    {
      panel: @panel_config.merge(type: @panel_type),
      stories: @stories&.as_json(include: :owners),
      iterations: @panel_config[:render_iterations] ? recent_iterations : nil,
      current_iteration: @panel_config[:render_iteration] ? current_iteration : nil
    }
  end

  def recent_iterations
    # Implement your iteration logic here
    Array.new(4) { |i| iteration_data(416 + i, 17 + (i*7)) }
  end

  def current_iteration
    iteration_data(420, 14)
  end

  def iteration_data(number, start_day)
    {
      number: number,
      start_date: "#{start_day} #{start_day > 31 ? 'Apr' : 'Mar'}",
      end_date: "#{start_day + 6} #{start_day > 31 ? 'Apr' : 'Mar'}",
      points: 0,
      team_strength: 100
    }
  end
end
