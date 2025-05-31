FactoryBot.define do
  factory :notification_setting do
    user { association :user }

    # In-app notification defaults
    in_app_story_creation { :yes }
    in_app_comments { :all }
    in_app_comment_source { :all_sources }
    in_app_story_state_changes { :all }
    in_app_blockers { :all }
    in_app_comment_reactions { :yes }
    in_app_reviews { :yes }

    # Email notification defaults
    email_story_creation { :yes }
    email_comments { :all }
    email_comment_source { :all_sources }
    email_story_state_changes { :all }
    email_blockers { :all }
    email_comment_reactions { :yes }
    email_reviews { :yes }

    # States
    in_app_state { :enabled }
    email_state { :enabled }

    trait :in_app_only do
      in_app_state { :enabled }
      email_state { :disabled }
    end

    trait :email_only do
      in_app_state { :disabled }
      email_state { :enabled }
    end

    trait :both_disabled do
      in_app_state { :disabled }
      email_state { :disabled }
    end

    trait :minimal_notifications do
      in_app_story_creation { :no }
      in_app_comments { :mentions_only }
      in_app_story_state_changes { :relevant }
      in_app_blockers { :followed_stories }
      in_app_comment_reactions { :no }
      in_app_reviews { :no }

      email_story_creation { :no }
      email_comments { :mentions_only }
      email_story_state_changes { :relevant }
      email_blockers { :followed_stories }
      email_comment_reactions { :no }
      email_reviews { :no }
    end
  end
end
