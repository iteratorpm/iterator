class Projects::StoriesController < ApplicationController

  before_action :set_project

  def update
    if @story.update(story_params)
      if story_params.key?(:estimate)
        @story.project.recalculate_iterations
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

end
