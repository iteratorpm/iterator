FactoryBot.define do
  factory :comment do
    content { "Mentioning @someone" }
    association :author, factory: :user

    association :commentable, factory: :story

    trait :for_story do
      association :commentable, factory: :story
    end

    trait :for_epic do
      association :commentable, factory: :epic
    end
  end
end
