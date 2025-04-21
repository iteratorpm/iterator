class Analytics::EpicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def index
    @epics = @project.epics.includes(:stories)
    respond_to do |format|
      format.html
      format.csv { send_data generate_csv, filename: "epics-report-#{Date.today}.csv" }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
    authorize! :read, @project
  end

  def generate_csv
    CSV.generate do |csv|
      csv << ["Epic Name", "Total Points", "Accepted", "In Progress", "Unstarted", "Iceboxed", "Completion"]
      @epics.each do |epic|
        csv << [
          epic.name,
          epic.total_points,
          epic.accepted_points,
          epic.in_progress_points,
          epic.unstarted_points,
          epic.iceboxed_points,
          "#{epic.completion_percentage}%"
        ]
      end
    end
  end
end
