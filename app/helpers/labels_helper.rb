module LabelsHelper
  def unaccepted_stories_count(label)
    label.stories.where.not(state: :accepted).count
  end
end
