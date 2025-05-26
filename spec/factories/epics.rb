FactoryBot.define do
  factory :epic do
    project
    name { Faker::Lorem.unique.sentence }
    external_link { Faker::Internet.url }

    trait :with_stories do
      after(:create) do |epic|
        create_list(:story, 2, project: epic.project, epic: epic)
      end
    end

    trait :with_label do
      after(:create) do |epic|
        create(:label, project: epic.project, epic: epic)
      end
    end
  end
end
