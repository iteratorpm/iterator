class Projects::EpicsController < Projects::BaseController
  before_action :set_epic, only: [:edit, :show, :update, :destroy]
  authorize_resource only: [:edit, :show, :update, :destroy]

  def index
    @panel_id = "epics_panel"
    @epics = @project.epics.includes(:stories, :label).ranked
  end

  def new
    @epic = @project.epics.new
    authorize! :new, @epic
  end

  def create
    @epic = @project.epics.build(epic_params)
    authorize! :create, @epic

    if @epic.save
      handle_successful_save
    else
      respond_to do |format|
        format.html { render_turbo_validation_errors(@epic) }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    if @epic.update(epic_params)
      handle_successful_update
    else
      respond_to do |format|
        format.json
        format.html { render_turbo_validation_errors(@epic) }
      end
    end
  end

  def destroy
    if @epic.destroy
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(@epic)
        end
        format.html do
          redirect_to project_epics_path(@project),
            notice: 'Epic was successfully deleted.'
        end
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to project_epics_path(@project),
            alert: 'Failed to delete epic.'
        end
        format.json { render json: { error: 'Failed to delete epic' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_epic
    @epic = @project.epics.find(params[:id])
  end

  def epic_params
    params.require(:epic).permit(
      :name,
      :description,
      :label_id,
      :external_link,
      :position,
      position: [:before, :after],
      comments_attributes: [
        :content,
        attachments: []
      ]
    )
  end

  def handle_successful_save
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend(
            "column-epics",
            partial: "projects/epics/epic",
            locals: { epic: @epic }
          )
        ]
      end
      format.html { redirect_to project_epics_path(@project), notice: 'Epic was successfully created.' }
    end
  end

  def handle_successful_update
    respond_to do |format|
      format.json
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          @epic,
          partial: "projects/epics/epic",
          locals: { epic: @epic }
        )
      end
      format.html { redirect_to project_epics_path(@project), notice: 'Epic was successfully updated.' }
    end
  end
end
