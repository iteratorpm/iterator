module PanelsHelper
  def iteration_time_from iteration
    Time.use_zone(iteration.project.time_zone) do
      "#{iteration.start_date.in_time_zone.strftime('%b %d')} – #{iteration.end_date.in_time_zone.strftime('%b %d')}"
    end
  end
end
