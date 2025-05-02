class Projects::LabelsController < Projects::BaseController

  def index
    @labels = @project.labels.order(name: :asc)
  end

end
