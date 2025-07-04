module ProjectsHelper
  def iteration_time_from iteration
    Time.use_zone(iteration.project.time_zone) do
      "#{iteration.start_date.in_time_zone.strftime('%b %d')} – #{iteration.end_date.in_time_zone.strftime('%b %d')}"
    end
  end

  def panel(panel_id, velocity: false, add_story: false, close: false, actions: false, add_epic: false, add_label: false, title: nil, &block)
    turbo_frame_tag panel_id do
      content_tag(:div, class: "flex flex-col h-full min-w-2xs overflow-hidden",
                        data: { panel_id: panel_id, controller: "panel" }, style: "width: 100%") do
        safe_join([
          render("projects/panel_header", velocity: velocity, add_story: add_story, add_label: add_label, add_epic: add_epic, close: close,
                                actions: actions, title: title || panel_id.to_s.titleize),
          content_tag(:section, class: "flex-1 overflow-y-auto overflow-x-hidden") do
            capture(&block) if block_given?
          end
        ])
      end
    end
  end

  def project_public_link project
    project_url(project)
  end

  def point_scale_values(project)
    case project.point_scale
    when 'linear_0123'
      [0, 1, 2, 3]
    when 'fibonacci'
      [0, 1, 2, 3, 5, 8]
    when 'powers_of_2'
      [0, 1, 2, 4, 8]
    when 'custom'
      project.point_scale_custom&.split(',')&.map(&:strip)
    else
      [0, 1, 2, 3]
    end
  end
end
