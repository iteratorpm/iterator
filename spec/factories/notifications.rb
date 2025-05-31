FactoryBot.define do
  factory :notification do
    user { association :user }
    notification_type { "story_created" }
    message { "Test notification" }
    delivery_method { "in_app" }

    trait :email do
      delivery_method { "email" }
    end

    trait :story_created do
      notification_type { "story_created" }
      message { "New story 'Test Story' was created" }
      notifiable { association :story }
    end

    trait :comment_created do
      notification_type { "comment_created" }
      message { "New comment on story 'Test Story'" }
      notifiable { association :comment }
    end

    trait :mention_in_comment do
      notification_type { "mention_in_comment" }
      message { "You were mentioned in a comment" }
      notifiable { association :comment }
    end
  end
end
