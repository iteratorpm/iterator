class Projects::PanelsController < ApplicationController
  before_action :set_project
  before_action :set_panel_data

  PANEL_TYPES = {
    'done' => { title: 'Done', render_iterations: true },
    'current' => { title: 'Current Iteration', render_iteration: true },
    'current_backlog' => { title: 'Current Iteration/Backlog', render_iteration: true },
    'backlog' => { title: 'Backlog', render_iteration: true },
    'icebox' => { title: 'Icebox' },
    'epics' => { title: 'Epics', render_epics: true }
  }.freeze

  def show
    respond_to do |format|
      format.html {
        @done_iterations = done_iterations
        @current_iteration_data = current_iteration_data
      }
      format.json { render json: panel_json }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])

    authorize! :read, @project
  end

  def set_panel_data
    @panel_type = params[:panel]
    @panel_config = PANEL_TYPES.fetch(@panel_type)
    @stories = fetch_stories_for_panel
  end

  def fetch_stories_for_panel
    case @panel_type
    when 'done'
      # Done panel shows all done stories grouped by iteration (oldest first)
      @project.stories.done.includes(:iteration).order('iterations.start_date ASC, stories.position ASC')
    when 'current'
      # Current iteration shows stories in the current iteration
      current_iteration = @project.find_or_create_current_iteration
      current_iteration.stories.ranked || Story.none
    when 'current_backlog'
      # Current + next iterations (backlog)
      current_iteration = @project.find_or_create_current_iteration
      iteration_ids = [current_iteration.id] + @project.iterations.backlog.pluck(:id)
      @project.stories.where(iteration_id: iteration_ids).ranked
    when 'backlog'
      # All stories in future iterations
      @project.stories.where(iteration: @project.iterations.backlog).ranked
    when 'icebox'
      # Stories without iteration and unscheduled state
      @project.stories.where(state: 'unscheduled').ranked
    when 'epics'
      # Epics would be handled differently
      nil
    else
      Story.none
    end
  end

  def panel_json
    {
      panel: @panel_config.merge(type: @panel_type),
      stories: @stories&.as_json(include: [:owners, :iteration]),
      iterations: @panel_config[:render_iterations] ? done_iterations : nil,
      current_iteration: @panel_config[:render_iteration] ? current_iteration_data : nil
    }
  end

  def done_iterations
    # Get iterations that have done stories, ordered oldest first
    @project.iterations.joins(:stories)
            .where(stories: { state: 'done' })
            .distinct
            .order(start_date: :asc)
            .as_json(only: [:id, :number, :start_date, :end_date], methods: [:total_points])
  end

  def current_iteration_data
    iteration = @project.find_or_create_current_iteration

    {
      id: iteration.id,
      number: iteration.number,
      start_date: iteration.start_date.to_s,
      end_date: iteration.end_date.to_s,
      points: iteration.total_points,
      velocity: @project.velocity,
      team_strength: iteration.team_strength
    }
  end
end
