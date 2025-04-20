class ProjectRelayJob < ApplicationJob
  queue_as :default

  def perform(project_id, action)
    project = Project.find(project_id)
    ActionCable.server.broadcast(
      "project_#{project_id}",
      action: action,
      project_id: project_id,
      timestamp: Time.current.to_i
    )
  end
end
