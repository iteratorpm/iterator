class Projects::CsvImportsController < ApplicationController
  before_action :set_project

  def index
  end

  def create
    if params[:csv_file].present?
      content = params[:csv_file].read
    elsif params[:csv_content].present?
      content = params[:csv_content]
    else
      return redirect_to project_csv_imports_path(@project), alert: 'Please provide CSV content'
    end

    begin
      result = CsvImportService.new(@project, content).import
      if result[:success]
        redirect_to project_stories_path(@project), notice: "Imported #{result[:created]} new items, updated #{result[:updated]} existing items"
      else
        @errors = result[:errors]
        render :new
      end
    rescue => e
      redirect_to project_csv_imports_path(@project), alert: "Import failed: #{e.message}"
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
