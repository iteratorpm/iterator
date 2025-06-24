class Projects::CsvExportsController < ApplicationController
  before_action :set_project

  def index
    @exports = @project.csv_exports.recent
    @new_export = @project.csv_exports.new
  end

  def create
    @export = @project.csv_exports.new(export_params.merge(status: 'queued'))

    if @export.save
      CsvExportJob.perform_later(@export.id)
      redirect_to project_csv_exports_path(@project), notice: 'Export started successfully'
    else
      @exports = @project.csv_exports.recent
      render :index
    end
  end

  def download
    @export = @project.csv_exports.find(params[:id])

    if @export.completed?
      send_file @export.full_file_path, filename: @export.filename
    else
      redirect_to project_csv_exports_path(@project), alert: 'Export not ready yet'
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def export_params
    params.require(:csv_export).permit(options: [])
  end
end
