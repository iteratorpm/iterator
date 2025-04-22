class IterationService
  def self.update_current_iteration(project)
    current_iteration = project.iterations.current.first

    # Complete past iterations
    project.iterations.where("end_date < ?", Date.current).each do |iteration|
      iteration.complete!
    end

    # Create new current iteration if needed
    unless current_iteration
      current_iteration = project.create_current_iteration
      current_iteration.update(current: true)
    end

    # Fill current iteration with stories
    current_iteration.fill_from_backlog

    # Recalculate future iterations
    project.recalculate_iterations
  end

  def self.override_iteration_length(iteration, new_length_weeks)
    iteration.update(end_date: iteration.start_date + new_length_weeks.weeks - 1.day)
    iteration.project.recalculate_iterations
  end
end
