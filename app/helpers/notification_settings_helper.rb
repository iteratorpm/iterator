module NotificationSettingsHelper

  # Story State Options and Display
  def story_state_options
    [
      ["No state changes", "no"],
      ["State changes relevant to me", "relevant"],
      ["All state changes, on stories I follow", "on_followed"],
      ["All state changes, on all stories in a project", "all"]
    ]
  end

  def story_state_value(db_value)
    case db_value
    when 0 then "no"
    when 1 then "relevant"
    when 2 then "on_followed"
    when 3 then "all"
    else "relevant"
    end
  end

  def story_state_display(db_value)
    case db_value
    when 0 then "No state changes"
    when 1 then "State changes relevant to me"
    when 2 then "All state changes, on stories I follow"
    when 3 then "All state changes, on all stories in a project"
    else "State changes relevant to me"
    end
  end

  # Comment Options and Display
  def comment_options
    [
      ["No Comments", "no"],
      ["Mentions only", "mentions"],
      ["All comments, on stories/epics I follow", "on_followed"],
      ["All comments, on all stories/epics in a project", "all"]
    ]
  end

  def comment_value(db_value)
    case db_value
    when 0 then "no"
    when 1 then "mentions"
    when 2 then "on_followed"
    when 3 then "all"
    else "on_followed"
    end
  end

  def comment_display(db_value)
    case db_value
    when 0 then "No comments"
    when 1 then "Mentions only"
    when 2 then "All comments, on stories/epics I follow"
    when 3 then "All comments, on all stories/epics in a project"
    else "All comments, on stories/epics I follow"
    end
  end

  # Blocker Options and Display
  def blocker_options
    [
      ["No Blockers", "no"],
      ["All blockers, on stories I follow", "on_followed"],
      ["All blockers, on all stories in a project", "all"]
    ]
  end

  def blocker_value(db_value)
    case db_value
    when 0 then "no"
    when 1 then "on_followed"
    when 2 then "all"
    else "on_followed"
    end
  end

  def blocker_display(db_value)
    case db_value
    when 0 then "No blockers"
    when 1 then "All blockers, on stories I follow"
    when 2 then "All blockers, on all stories in a project"
    else "All blockers, on stories I follow"
    end
  end

  # Reaction Options and Display
  def reaction_options
    [
      ["No reactions", "no"],
      ["All reactions to my comments", "yes"]
    ]
  end

  def reaction_value(db_value)
    case db_value
    when 0 then "no"
    when 1 then "yes"
    else "yes"
    end
  end

  def reaction_display(db_value)
    case db_value
    when 0 then "No reactions"
    when 1 then "All reactions to my comments"
    else "All reactions to my comments"
    end
  end

  # Review Options and Display
  def review_options
    [
      ["No reviews", "no"],
      ["Only reviews that I own", "owned"],
      ["All reviews on stories I follow", "all"]
    ]
  end

  def review_value(db_value)
    case db_value
    when 0 then "no"
    when 1 then "owned"
    when 2 then "all"
    else "owned"
    end
  end

  def review_display(db_value)
    case db_value
    when 0 then "No reviews"
    when 1 then "Only reviews that I own"
    when 2 then "All reviews on stories I follow"
    else "Only reviews that I own"
    end
  end

  # Commit Options and Display
  def commit_options
    [
      ["No commits", "no"],
      ["Commits on stories I follow", "on_followed"],
      ["Commits on all stories in a project", "all"]
    ]
  end

  def commit_value(db_value)
    case db_value
    when 0 then "no"
    when 1 then "on_followed"
    when 2 then "all"
    else "no"
    end
  end

  def commit_display(db_value)
    case db_value
    when 0 then "No commits"
    when 1 then "Commits on stories I follow"
    when 2 then "All commits on stories in a project"
    else "No commits"
    end
  end

  # Task Options and Display
  def task_options
    [
      ["No Tasks", "no"],
      ["Mentions only", "mentions"]
    ]
  end

  def task_value(db_value)
    case db_value
    when 0 then "no"
    when 1 then "mentions"
    else "mentions"
    end
  end

  def task_display(db_value)
    case db_value
    when 0 then "No tasks"
    when 1 then "Mentions only"
    else "Mentions only"
    end
  end
end
