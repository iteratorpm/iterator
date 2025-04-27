class Projects::StoriesController < ApplicationController
  load_and_authorize_resource
  before_action :set_project

  def new
    @story = @project.stories.new
  end

  def create
    @story = @project.stories.build(story_params)
    @story.position = params[:story][:position] if params[:story][:position].present?

    if @story.save
      handle_successful_save
    else
      handle_failed_save
    end
  end

  def show
    @story = @project.stories.find(params[:id])
  end

  def edit
    @story = @project.stories.find(params[:id])
  end

  def update
    if @story.update(story_params)
      handle_successful_update
    else
      handle_failed_update
    end
  end

  def destroy
    @story = @project.stories.find(params[:id])

    @story.destroy
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def story_params
    params.require(:story).permit(
      :title,
      :story_type,
      :release_date,
      :estimate,
      :requester_id,
      :blocked_by,
      :blocking,
      :description,
      :position,
      owner_ids: [],
      label_list: [],
      reviews_attributes: [
        :id,
        :review_type,
        :owner_id,
        :state,
        :_destroy
      ],
      comments_attributes: [
        :body,
        attachments: []
      ]
    )
  end

  def handle_successful_save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "stories_#{params[:panel]}",
          partial: "projects/stories/story",
          locals: { story: @story }
        )
      end
      format.html { redirect_to project_path(@project), notice: 'Story was successfully created.' }
    end
  end

  def handle_failed_save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "new_story_form_#{params[:panel]}",
          partial: "stories/form",
          locals: { story: @story, column: params[:column] }
        ), status: :unprocessable_entity
      end
      format.html { render :new }
    end
  end

  def handle_successful_update
    @story.project.recalculate_iterations if story_params.key?(:estimate)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@story),
          partial: "stories/story",
          locals: { story: @story }
        )
      end
      format.html { redirect_to project_path(@project), notice: 'Story was successfully updated.' }
    end
  end

  def handle_failed_update
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@story),
          partial: "stories/form",
          locals: { story: @story }
        ), status: :unprocessable_entity
      end
      format.html { render :edit }
    end
  end
end
