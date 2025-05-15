class Projects::StoriesController < Projects::BaseController
  before_action :set_story, only: [:edit, :show, :update, :destroy, :reject, :rejection]
  authorize_resource only: [:edit, :show, :update, :destroy]

  def my_work
    @stories = @project.stories
      .by_owner(current_user.id)
      .ranked
  end

  def icebox
    @stories = @project.stories.icebox.ranked
  end

  def blocked
    @stories = @project.stories.blocked.ranked
  end

  def new
    @story = @project.stories.new

    authorize! :new, @story
  end

  def create
    @story = @project.stories.build(story_params)
    authorize! :create, @story

    story, success = StoryService.create(@project, @story)

    if success
      handle_successful_save
    else
      respond_to do |format|
        format.turbo_stream { render_turbo_validation_errors(@story) }
        format.html { render :new }
      end
    end
  end

  def show
  end

  def edit
  end

  def update

    service = StoryService.new(@story, current_user)

    if service.update(story_params)
      handle_successful_update
    else
      respond_to do |format|
        format.json
        format.turbo_stream { render_turbo_validation_errors(@story) }
        format.html { render :edit }
      end
    end
  end

  def destroy

    service = StoryService.new(@story)
    if service.destroy
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(@story)
        end
        format.html do
          redirect_to project_path(@project),
            notice: 'Story was successfully deleted.'
        end
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to project_path(@project),
            alert: 'Failed to delete story.'
        end
        format.json { render json: { error: 'Failed to delete story' }, status: :unprocessable_entity }
      end
    end
  end

  def rejection
    authorize! :read, @story
  end

  def reject
    authorize! :update, @story

    comment_body = params[:story][:comment]

    if comment_body.present?
      @story.comments.create!(
        content: comment_body,
        author: current_user
      )
    end

    service = StoryService.new(@story, current_user)

    if service.update({state: :rejected})
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to project_story_path(@project, @story)
        end
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to project_path(@project),
            alert: 'Failed to reject the story.'
        end
        format.json { render json: { error: 'Failed to reject the story' }, status: :unprocessable_entity }
      end
    end

  end

  def batch_update
    recalculate_after = false

    ActiveRecord::Base.transaction do
      story_updates = params[:stories] || []

      story_updates.each do |story_update|
        story = @project.stories.find(story_update[:id])
        authorize! :update, story

        service = StoryService.new(story, current_user)
        success = service.update(story_update.permit(allowed_story_params), recalculate: false)

        # If any update would trigger recalculation, flag for later
        recalculate_after ||= success && story.iteration_recalculation_needed?

        raise ActiveRecord::Rollback unless success
      end

      # Perform a single recalculation after all updates if needed
      @project.recalculate_iterations if recalculate_after
    end

    respond_to do |format|
      format.html { redirect_to project_path(@project), notice: 'Stories were successfully updated.' }
      format.json { head :no_content }
    end
  end

  private

  def set_story
    @story = @project.stories.find(params[:id])
  end

  def story_params
    params.require(:story).permit(
      :name,
      :add_label,
      :column,
      :story_type,
      :release_date,
      :estimate,
      :requester_id,
      :state,
      :epic_id,
      :blocked_by,
      :blocking,
      :description,
      :position,
      position: [:before, :after],
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
        :content,
        attachments: []
      ]
    )
  end

  def handle_successful_save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.prepend(
          "column-icebox",
          partial: "projects/stories/story",
          locals: { story: @story }
        )
      end
      format.html { redirect_to project_path(@project), notice: 'Story was successfully created.' }
    end
  end

  def handle_successful_update
    respond_to do |format|
      format.json
      format.turbo_stream
      format.html { redirect_to project_path(@project), notice: 'Story was successfully updated.' }
    end
  end

end
