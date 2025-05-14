class Projects::CommentsController < Projects::BaseController
  before_action :set_story

  def create
    @comment = @story.comments.new(comment_params)
    @comment.author = current_user

    if @comment.save
      if params[:comment][:attachments]
        @comment.attachments.attach(params[:comment][:attachments])
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to project_story_path(@project, @story) }
      end
    else
      # handle validation error if needed
      render turbo_stream: turbo_stream.replace(
        "new_comment_form",
        partial: "comments/form",
        locals: { comment: @comment }
      )
    end
  end

  def destroy
    @comment = @story.comments.find(params[:id])
    authorize! :destroy, @comment
    @comment.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to project_story_path(@project, @story) }
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

  def set_story
    @project = Project.find(params[:project_id])
    @story = @project.stories.find(params[:story_id])
  end

  def comment_params
    params.require(:comment).permit(:content, attachments: [])
  end
end
