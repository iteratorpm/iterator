class Projects::LabelsController < Projects::BaseController
  before_action :set_label, only: [:edit, :update, :destroy, :convert_to_epic]
  authorize_resource only: [:edit, :update, :destroy, :convert_to_epic]

  def index
    @labels = @project.labels.includes(:stories).order(name: :asc)
    @panel_id = "labels_panel"
  end


  def create
    @label = @project.labels.new(label_params)
    if @label.save
      redirect_to project_labels_path(@project), notice: 'Label was successfully created.'
    else
      @labels = @project.labels.includes(:stories)
      @new_label = @label
      render :index
    end
  end

  def edit
  end

  def update
    if @label.update(label_params)
      redirect_to project_labels_path(@project), notice: 'Label was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @label.destroy
    redirect_to project_labels_path(@project), notice: 'Label was successfully destroyed.'
  end

  def convert_to_epic
    @label.update(label_type: :epic)
    redirect_to project_labels_path(@project), notice: 'Label was successfully converted to epic.'
  end

  private

  def set_label
    @label = @project.labels.find(params[:id])
  end

  def label_params
    params.require(:label).permit(:name, :label_type)
  end
end
