class IterationMaintenanceJob < ApplicationJob
  def perform
    Project.active.find_each do |project|
      project.plan_current_iteration
    end
  end
end
