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

  # Generate appropriate classes based on story attributes
  def story_classes(story)
    classes = ["story-preview-item", "draggable"]

    # Add story type class
    classes << story.story_type if story.story_type.present?

    # Add priority class
    classes << "p#{story.priority}" if story.priority.present?

    # Add state class
    # classes << story.current_state if story.current_state.present?

    # Add estimate classes
    if story.estimate.present?
      classes << "estimate_#{story.estimate}"
    else
      classes << "estimate_-1"
    end

    classes << "is_estimatable" if story.estimatable?

    # Add task and comment related classes
    classes << "has_tasks" if story.tasks.any?
    classes << "comments" if story.comments.any?

    # Add blocker classes
    if story.has_blockers? || story.blocking_stories.any?
      classes << "has_blockers_or_blocking"
    end

    classes.join(" ")
  end

  # Determine border color class based on story type
  def border_color_class(story)
    case story.story_type
    when "feature"
      "border-green-500"
    when "bug"
      "border-red-500"
    when "chore"
      "border-gray-500"
    when "release"
      "border-purple-500"
    else
      "border-blue-500"
    end
  end

  # Get the appropriate icon for review status
  def review_status_icon(review)
    case review.state
    when "unstarted"
      "unstarted.svg"
    when "in_review"
      "in_review.svg"
    when "pass"
      "pass.svg"
    when "fail"
      "fail.svg"
    else
      "unstarted.svg"
    end
  end
end
