module AnalyticsHelper
  def story_type_color type
    return "blue" if type == "Feature"
    return "red" if type == "Bug"
    return "gray" if type == "Chore"
  end
end
