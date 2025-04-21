class ChartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def velocity
    @velocity_data = @project.calculate_velocity_data
    @stories_data = @project.calculate_stories_data
  end

  def composition
    @project = current_project # Assuming you have a way to get the current project
    @iterations = @project.iterations.order(start_date: :desc)
    @current_iteration = @iterations.first

    # Data for charts
    @accepted_stories_data = stories_composition_data(@project.stories.accepted)
    @created_stories_data = stories_composition_data(@project.stories.created_in_current_iteration)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
  private

  def stories_composition_data(stories)
    {
      features: stories.features.count,
      bugs: stories.bugs.count,
      chores: stories.chores.count
    }
  end
end
