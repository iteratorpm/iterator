module CycleTimeHelper
  def median_cycle_time_chart_data(iterations)
    iterations.map do |iteration|
      {
        name: iteration.display_name,
        data: [[iteration.start_date, iteration.median_cycle_time]]
      }
    end
  end
end
