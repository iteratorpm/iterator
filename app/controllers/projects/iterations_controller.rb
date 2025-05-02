class Projects::IterationsController < Projects::BaseController

  def done
    @iterations = @project.iterations.done.includes(:stories).order(start_date: :asc)
  end

  def current
    @current_iteration = @project.find_or_create_current_iteration
  end

  def current_backlog
    @current_iteration = @project.find_or_create_current_iteration
    @backlog_iterations = @project.iterations.backlog.includes(:stories)
  end

  def backlog
    @iterations = @project.iterations.backlog.includes(:stories)
  end

  def update
    @iteration.update!(team_strength: params[:team_strength])
    @iteration.project.recalculate_velocity
  end

end
