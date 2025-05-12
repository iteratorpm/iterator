class Projects::StoriesController < Projects::BaseController
  before_action :set_story, only: [:edit, :show, :update, :destroy]
  authorize_resource only: [:edit, :show, :update, :destroy]

  def my_work
    @stories = @project.stories
      .joins(:story_owners)
      .where(story_owners: { user_id: current_user.id })
      .ranked
  end

  def icebox
    @stories = @project.stories.icebox.ranked
  end

  def blocked
    @stories = @project.stories.joins(:blockers).distinct
  end

  def new
    @story = @project.stories.new

    authorize! :new, @story
  end

  def create
    @story = @project.stories.build(story_params)

    authorize! :create, @story

    @story.position = params[:story][:position] if params[:story][:position].present?

    if @story.save
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
    if @story.update(story_params)
      handle_successful_update
    else
      respond_to do |format|
        format.turbo_stream { render_turbo_validation_errors(@story) }
        format.html { render :edit }
      end
    end
  end

  def destroy

    if @story.destroy
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
        format.turbo_stream do
          # render turbo_stream: turbo_stream.replace(
          #   dom_id(@story),
          #   partial: "projects/stories/story",
          #   locals: { story: @story }
          # ), status: :unprocessable_entity
        end
        format.html do
          redirect_to project_path(@project),
            alert: 'Failed to delete story.'
        end
        format.json { render json: { error: 'Failed to delete story' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_story
    @story = @project.stories.find(params[:id])
  end

  def story_params
    params.require(:story).permit(
      :name,
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
        render turbo_stream: turbo_stream.prepend(
          "stories-icebox",
          partial: "projects/stories/story",
          locals: { story: @story }
        )
      end
      format.html { redirect_to project_path(@project), notice: 'Story was successfully created.' }
    end
  end

  def handle_successful_update
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to project_path(@project), notice: 'Story was successfully updated.' }
    end
  end

end
