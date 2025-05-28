FactoryBot.define do
  factory :notification_setting do
    user
    in_app_story_creation { :yes }
    in_app_story_state_changes { :all }
    in_app_comments { :all }
    in_app_state { :enabled }
    email_state { :enabled }
  end
end
