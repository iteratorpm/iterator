class IterationMaintenanceJob < ApplicationJob
  def perform
    Project.active.find_each do |project|
      IterationService.plan_current_iteration(project)
    end
  end
end
