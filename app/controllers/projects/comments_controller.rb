class Projects::CommentsController < Projects::BaseController
  before_action :set_commentable

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.author = current_user

    if @comment.save
      if params[:comment][:attachments]
        @comment.attachments.attach(params[:comment][:attachments])
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to commentable_path }
      end
    else
      render turbo_stream: turbo_stream.replace(
        "new_comment_form",
        partial: "comments/form",
        locals: { comment: @comment }
      )
    end
  end

  def destroy
    @comment = @commentable.comments.find(params[:id])
    authorize! :destroy, @comment
    @comment.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to commentable_path }
    end
  end

  def preview
    html = render_to_string(
      partial: "projects/shared/markdown_preview",
      formats: [:html],
      locals: { content: params.dig(:markdown, :content) }
    )

    render json: { html: html }
  end

  private

  def set_commentable
    @project = Project.find(params[:project_id])

    if params[:story_id]
      @commentable = @project.stories.find(params[:story_id])
    elsif params[:epic_id]
      @commentable = @project.epics.find(params[:epic_id])
    else
      raise ActiveRecord::RecordNotFound, "No commentable resource found"
    end
  end

  def commentable_path
    if @commentable.is_a?(Story)
      project_story_path(@project, @commentable)
    else
      project_epic_path(@project, @commentable)
    end
  end

  def comment_params
    params.require(:comment).permit(:content, attachments: [])
  end
end
