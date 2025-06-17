FactoryBot.define do
  factory :notification do
    user { association :user }
    notification_type { :review_assigned }
    read_at { Time.current }
    message { "Test notification" }
    association :project
    delivery_method { "in_app" }

    association :notifiable, factory: :story

    # Default: no notifiable set unless one of the traits is used

    trait :email do
      delivery_method { "email" }
    end

    trait :story_created do
      notification_type { "story_created" }
      message { "New story 'Test Story' was created" }
      association :notifiable, factory: :story
    end

    trait :comment_created do
      notification_type { "comment_created" }
      message { "New comment on story 'Test Story'" }
      association :notifiable, factory: :comment
    end

    trait :mention_in_comment do
      notification_type { "mention_in_comment" }
      message { "You were mentioned in a comment" }
      association :notifiable, factory: :comment
    end

    trait :unread do
      read_at { nil }
    end
  end
end
