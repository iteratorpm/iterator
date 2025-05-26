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

    trait :with_labels do
      after(:create) do |story|
        create_list(:label, 2, project: story.project)
        story.labels << Label.last(2)
      end
    end

    trait :with_epic do
      after(:create) do |story|
        epic = create(:epic, project: story.project)
        label = create(:label, project: epic.project, epic: epic)
        create :story_label, story: story, label: label
      end
    end

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
