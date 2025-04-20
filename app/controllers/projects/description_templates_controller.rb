class Projects::DescriptionTemplatesController < ApplicationController
  before_action :set_project
  before_action :set_template, only: [:edit, :update, :destroy]

  def index
    @templates = @project.description_templates
  end

  def new
    @template = @project.description_templates.new
  end

  def create
    @template = @project.description_templates.new(template_params)
    if @template.save
      redirect_to project_description_templates_path(@project), notice: 'Template created successfully'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @template.update(template_params)
      redirect_to project_description_templates_path(@project), notice: 'Template updated successfully'
    else
      render :edit
    end
  end

  def destroy
    @template.destroy
    redirect_to project_description_templates_path(@project), notice: 'Template deleted successfully'
  end

  def preview
    render json: {
      html: render_to_string(
        partial: 'projects/description_templates/preview',
        locals: { content: params[:template][:description] },
        formats: [:html]
      )
    }
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_template
    @template = @project.description_templates.find(params[:id])
  end

  def template_params
    params.require(:description_template).permit(:name, :description)
  end
end
