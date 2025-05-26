FactoryBot.define do
  factory :label do
    name { Faker::Lorem.unique.sentence }
    project

    trait :for_epic do
      association :epic, factory: :epic, project: project
    end
  end
end
