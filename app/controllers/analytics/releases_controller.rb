class Analytics::ReleasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def index
    @releases = @project.releases.order(deadline: :desc)
    respond_to do |format|
      format.html
      format.csv { send_data generate_csv, filename: "releases-report-#{Date.today}.csv" }
    end
  end

  def show
    @release = @project.releases.find(params[:id])
    authorize! :read, @release
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
    authorize! :read, @project
  end

  def generate_csv
    CSV.generate do |csv|
      csv << ["Release Name", "Total Points", "Points Remaining", "Scheduled Date", "Completion Date"]
      @releases.each do |release|
        csv << [
          release.name,
          release.total_points,
          release.points_remaining,
          release.deadline&.strftime("%b %d, %Y"),
          release.completion_date&.strftime("%b %d, %Y")
        ]
      end
    end
  end
end
