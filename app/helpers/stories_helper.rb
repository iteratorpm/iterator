module StoriesHelper
  def story_type_class(type)
    case type.downcase
    when 'feature' then 'bg-blue-100 text-blue-800'
    when 'bug' then 'bg-red-100 text-red-800'
    when 'chore' then 'bg-yellow-100 text-yellow-800'
    else 'bg-gray-100 text-gray-800'
    end
  end

  def story_state_class(state)
    case state.downcase
    when 'unstarted' then 'bg-gray-200 text-gray-800'
    when 'started' then 'bg-yellow-200 text-yellow-800'
    when 'finished' then 'bg-blue-200 text-blue-800'
    when 'delivered' then 'bg-purple-200 text-purple-800'
    when 'accepted' then 'bg-green-200 text-green-800'
    when 'rejected' then 'bg-red-200 text-red-800'
    else 'bg-gray-200 text-gray-800'
    end
  end
end
