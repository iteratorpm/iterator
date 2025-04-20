class Projects::ReviewTypesController < ApplicationController
  before_action :set_project
  before_action :set_review_type, only: [:update, :destroy, :toggle_hidden]

  def index
    @review_types = @project.review_types.visible
    @hidden_review_types = @project.review_types.hidden
    @new_review_type = @project.review_types.new
  end

  def create
    @review_type = @project.review_types.new(review_type_params)
    if @review_type.save
      redirect_to project_review_types_path(@project), notice: 'Review type created successfully'
    else
      @review_types = @project.review_types.visible
      render :index
    end
  end

  def update
    if @review_type.update(review_type_params)
      render json: { status: 'success', name: @review_type.name }
    else
      render json: { status: 'error', errors: @review_type.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @review_type.destroy
    head :no_content
  end

  def toggle_hidden
    @review_type.update(hidden: !@review_type.hidden)
    redirect_to project_review_types_path(@project), notice: 'Review type updated successfully'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_review_type
    @review_type = @project.review_types.find(params[:id])
  end

  def review_type_params
    params.require(:review_type).permit(:name)
  end
end
