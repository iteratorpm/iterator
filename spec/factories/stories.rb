FactoryBot.define do
  factory :story do
    project
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    sequence(:position)

    association :requester, factory: :user

    trait :accepted do
      state { "accepted" }
      accepted_at { 1.week.ago }
    end

    trait :done do
      panel { :done }
      state { "accepted" }
      accepted_at { 1.week.ago }
      association :iteration, factory: [:iteration, :past]
    end

    trait :current do
      panel { :current }
      association :iteration, factory: [:iteration, :current]
    end

    trait :backlog do
      panel { :backlog }
      association :iteration, factory: [:iteration, :future]
    end

    trait :icebox do
      panel { :ciebox }
      iteration { nil }
      state { "unstarted" }
    end

    trait :estimated do
      estimate { [1, 2, 3, 5, 8].sample }
    end

    trait :unestimated do
      estimate { nil }
    end
  end
end
