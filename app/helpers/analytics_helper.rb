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
end
