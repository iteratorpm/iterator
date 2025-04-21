class Analytics::CycleTimeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  before_action :set_iteration, only: [:show]

  def index
    @iterations = @project.iterations.order(start_date: :desc).limit(5)
    @stories = @iteration.stories.order(created_at: :desc)
    prepare_chart_data
  end

  def export
    @stories = @project.stories.with_cycle_time
    respond_to do |format|
      format.csv do
        send_data @stories.to_csv, filename: "cycle_time_#{Date.today}.csv"
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_iteration
    @iteration = @project.iterations.find(params[:id])
  end

  def prepare_chart_data
    @chart_data = @iterations.map do |iteration|
      stories = iteration.stories.where.not(cycle_time: nil)
      median = stories.median(:cycle_time)

      {
        name: iteration.display_name,
        start_date: iteration.start_date,
        median_cycle_time: median || 0
      }
    end
  end
end
