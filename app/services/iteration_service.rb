class IterationService
  def self.plan_current_iteration(project)
    Time.use_zone(project.time_zone) do
      # Complete past iterations
      project.iterations.where("end_date <= ?", Time.zone.today).each(&:complete!)

      # Find or create current iteration
      current_iteration = project.iterations.current.first ||
                         project.iterations.for_date(Time.zone.today).first ||
                         project.create_current_iteration

      # Fill current iteration
      current_iteration.calculated_velocity
      current_iteration.fill_from_backlog

      current_iteration
    end
  end

end
