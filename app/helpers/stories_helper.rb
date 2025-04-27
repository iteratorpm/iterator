module StoriesHelper

  # Generate appropriate classes based on story attributes
  def story_classes(story)
    classes = ["story-preview-item", "cursor-move"]

    classes << "bg-blue-100" if story.icebox?

    classes << "bg-yellow-100" if story.current?

    classes << "bg-green-100" if story.done?

    classes << border_color_class(story)

    classes.join(" ")
  end

  # Determine border color class based on story type
  def border_color_class(story)
    case story.story_type
    when "feature"
      "border-yellow-500"
    when "bug"
      "border-red-500"
    when "chore"
      "border-gray-500"
    when "release"
      "border-blue-500"
    else
      "border-purple-500"
    end
  end

  def story_color_class(story)
    case story.story_type
    when "feature"
      "text-yellow-500"
    when "bug"
      "text-red-500"
    when "chore"
      "text-gray-500"
    when "release"
      "text-blue-500"
    else
      "text-purple-500"
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
