class Projects::ProfileController < ApplicationController
  before_action :set_project

  def show
  end

  def update
    if @project.update(project_profile_params)
      redirect_to profile_project_path(@project), notice: "Profile updated successfully"
    else
      render :profile
    end
  end

  def preview
    respond_to do |format|
      format.json do
        render json: {
          html: render_to_string(
            partial: 'projects/shared/markdown_preview',
            locals: { content: params[:content] },
            formats: [:html]
          )
        }
      end
    end
  end


  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_profile_params
    params.require(:project).permit(:profile_content)
  end
end
