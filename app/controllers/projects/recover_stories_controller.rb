class Projects::RecoverStoriesController < ApplicationController
  before_action :set_project
  before_action :set_story, only: [:create]

  def index
    @deleted_stories = @project.stories.discarded.order(deleted_at: :desc)
  end

  def create
    if @story.restore
      ProjectRelayJob.perform_later(@project.id, "story_recovered")
      redirect_to recover_stories_project_path(@project), notice: "Story recovered successfully"
    else
      redirect_to recover_stories_project_path(@project), alert: "Failed to recover story"
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_story
    @story = @project.stories.discarded.find(params[:id])
  end
end
