class Projects::EpicsController < Projects::BaseController

  def index
    @epics = @project.epics.includes(:stories).order(name: :asc)
  end

end
