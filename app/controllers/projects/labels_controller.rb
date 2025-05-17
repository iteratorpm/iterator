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
      handle_successful_update
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

    handle_successful_update
  end

  private

  def set_label
    @label = @project.labels.find(params[:id])
  end

  def label_params
    params.require(:label).permit(:name, :label_type)
  end

  def handle_successful_update
    respond_to do |format|
      format.json
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          @label,
          partial: "projects/labels/label",
          locals: { label: @label }
        )
      end
      format.html { redirect_to project_labels_path(@project), notice: 'Label was successfully updated.' }
    end
  end
end
