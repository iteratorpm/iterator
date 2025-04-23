class IterationService
  def self.plan_current_iteration(project)
    Time.use_zone(project.time_zone) do
      # Complete past iterations
      project.iterations.where("end_date <= ?", Time.zone.today).each(&:complete!)

      # Find or create current iteration
      current_iteration = project.find_or_create_current_iteration

      project.recalculate_iterations

      current_iteration
    end
  end

end
