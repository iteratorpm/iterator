FactoryBot.define do
  factory :project do
    name { Faker::App.name }
    organization
    description { "Project description" }
    iteration_start_day { 0 }
    time_zone { "Eastern Time (US & Canada)" }
    automatic_planning { true }

    trait :with_members do
      after(:create) do |project|
        create(:project_membership, project: project, user: create(:user))
      end
    end
  end
end
