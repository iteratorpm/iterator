FactoryBot.define do
  factory :muted_project do
    user { association :user }
    project { association :project }
    mute_type { :all_notifications }

    trait :except_mentions do
      mute_type { :except_mentions }
    end
  end
end
