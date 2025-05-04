class Projects::LabelsController < Projects::BaseController

  def index
    @labels = @project.labels.order(name: :asc)
    @panel_id = "labels_panel"
  end

end
