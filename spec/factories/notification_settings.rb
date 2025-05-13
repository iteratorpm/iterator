FactoryBot.define do
  factory :notification_setting do
    user
    project
    story_creation { :yes }
    story_state_changes { :all }
    comments { :all }
    in_app_state { :enabled }
    email_state { :enabled }
  end
end
