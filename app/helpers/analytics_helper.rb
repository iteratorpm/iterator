module AnalyticsHelper
  def story_type_color type
    return "blue" if type == "Feature"
    return "red" if type == "Bug"
    return "gray" if type == "Chore"
  end

  def status_border_color(status)
    case status
    when 'accepted' then 'border-green-500'
    when 'delivered' then 'border-orange-500'
    when 'finished' then 'border-blue-500'
    when 'started' then 'border-yellow-500'
    else 'border-gray-300'
    end
  end

  def status_bg_color(status)
    case status
    when 'accepted' then 'bg-green-50'
    when 'delivered', 'finished', 'started' then 'bg-yellow-50'
    else 'bg-white'
    end
  end

  def story_icon(story)
    case story.story_type
    when 'feature' then svg_inline('star', class: 'w-4 h-4')
    when 'bug' then svg_inline('bug', class: 'w-4 h-4')
    when 'chore' then svg_inline('chore', class: 'w-4 h-4')
    else svg_inline('default', class: 'w-4 h-4')
    end
  end

  def activity_color(event)
    case event
    when 'accepted' then 'green'
    when 'delivered' then 'yellow'
    when 'finished' then 'blue'
    when 'started' then 'yellow'
    when 'unscheduled' then 'blue'
    when 'scheduled' then 'gray'
    when 'deleted' then 'red'
    else 'gray'
    end
  end
end
