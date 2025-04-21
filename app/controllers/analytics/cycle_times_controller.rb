class Analytics::CycleTimesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def index
    @iterations = @project.iterations.order(start_date: :desc).limit(5)
    @stories = @project.current_iteration.stories.order(created_at: :desc)
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

  def prepare_chart_data
    @chart_data = @iterations.map do |iteration|
      # stories = iteration.stories.where.not(cycle_time: nil)
      # cycle_times = stories.pluck(:cycle_time).sort
      #
      # median = if cycle_times.empty?
      #            nil
      #          else
      #            mid = cycle_times.length / 2
      #            if cycle_times.length.odd?
      #              cycle_times[mid]
      #            else
      #              (cycle_times[mid - 1] + cycle_times[mid]) / 2.0
      #            end
      #          end

      {
        name: iteration.display_name,
        start_date: iteration.start_date,
        median_cycle_time: 0
        # median_cycle_time: median || 0
      }
    end
  end

end
