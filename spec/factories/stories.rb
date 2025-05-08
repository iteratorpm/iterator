FactoryBot.define do
  factory :story do
    project
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    estimate { 3 }
    sequence(:position)
    story_type { :feature }
    state { :unscheduled }
    iteration { nil }

    association :requester, factory: :user

    trait :accepted do
      state { "accepted" }
      accepted_at { 1.week.ago }
    end

    trait :done do
      state { "accepted" }
      accepted_at { 1.week.ago }
      association :iteration, factory: [:iteration, :done]
    end

    trait :current do
      state { :started }
      association :iteration, factory: [:iteration, :current]
    end

    trait :backlog do
      state { :unstarted }
      association :iteration, factory: [:iteration, :backlog]
    end

    trait :icebox do
      state { :unscheduled }
      iteration { nil }
    end

    trait :estimated do
      estimate { [1, 2, 3, 5, 8].sample }
    end

    trait :unscheduled do
      state { :unscheduled }
      iteration { nil }
    end

    trait :unstarted do
      state { :unstarted }
    end

    trait :started do
      state { :started }
    end

    trait :delivered do
      state { :delivered }
    end

    trait :accepted do
      state { :accepted }
    end

    trait :rejected do
      state { :rejected }
    end

    trait :unestimated do
      estimate { -1 }
    end
  end
end
