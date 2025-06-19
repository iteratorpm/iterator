module StoriesHelper

  # Generate appropriate classes based on story attributes
  def story_classes(story)
    classes = ["story-header"]

    if story.done?
      classes << "bg-green-100 hover:bg-green-200 text-gray-800"
    else

      classes << "cursor-move"

      if story.release?
        classes << "bg-sky-700 hover:bg-sky-800 text-gray-100"
      else
        classes << "text-gray-800"

        classes << "bg-blue-100 hover:bg-blue-200" if story.icebox?

        classes << "bg-yellow-100 hover:bg-yellow-200" if story.current?

        classes << "bg-gray-50 hover:bg-gray-200" if story.backlog?
      end
    end

    classes.join(" ")
  end

  def story_type_icon story
    type = (story.respond_to? :story_type) ? story.story_type : story.downcase

    inline_svg_tag("icons/#{type}.svg", class: "h-4 w-4 #{story_color_class(type)}", title: type.capitalize)
  end

  def story_point_icon story
    estimate = (story.respond_to? :estimate) ? story.estimate : story

    if estimate == -1
        image_tag "icons/unestimated.svg", class: "h-8 w-6", title: "Point #{estimate}"
    elsif estimate > 0 && estimate <= 8
      image_tag "icons/point-#{estimate}.svg", class: "h-8 w-6", title: "Point #{estimate}"
    else
      content_tag :div, class: "h-8 w-6" do
      end
    end
  end

  def story_color_class(story_type)
    case story_type
    when "feature"
      "text-yellow-500"
    when "bug"
      "text-red-500"
    when "chore"
      "text-gray-500"
    when "release"
      "text-gray-900"
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

  def story_state_options(story)
    case story.story_type.to_sym
    when :feature, :bug
      [
        ["unstarted", "Unstarted"],
        ["started", "Started"],
        ["finished", "Finished"],
        ["delivered", "Delivered"],
        ["accepted", "Accepted"],
        ["rejected", "Rejected"]
      ]
    when :chore
      [
        ["unstarted", "Unstarted"],
        ["started", "Started"],
        ["finished", "Finished"],
        ["accepted", "Accepted"],
        ["rejected", "Rejected"]
      ]
    when :release
      [
        ["unscheduled", "Unscheduled"],
        ["unstarted", "Unstarted"],
        ["started", "Started"],
        ["accepted", "Accepted"]
      ]
    else
      []  # Fallback for unknown types
    end
  end

  def story_action_button_config(state)
    case state.to_sym
    when :started
      { label: "Start", classes: "bg-gray-100 text-gray-800 hover:bg-gray-200", icon: nil, value: "started" }
    when :finished
      { label: "Finish", classes: "bg-blue-700 text-gray-200 hover:bg-blue-800", icon: nil, value: "finished" }
    when :delivered
      { label: "Deliver", classes: "bg-amber-600 text-gray-200 hover:bg-amber-700", icon: nil, value: "delivered" }
    when :accepted
      { label: "Accept", classes: "bg-lime-700 text-gray-200 hover:bg-lime-800", icon: nil, value: "accepted" }
    when :rejected
      { label: "Reject", classes: "bg-red-700 text-gray-200 hover:bg-red-800", icon: nil, value: "rejected" }
    when :restarted
      { label: "Restart", classes: "bg-gray-100 text-gray-800 hover:bg-gray-200", icon: "icons/restart.svg", value: "started" }
    else
      { label: state.to_s.humanize, classes: "bg-gray-300 text-gray-800", icon: nil, value: state }
    end
  end
end
