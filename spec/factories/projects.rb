FactoryBot.define do
  factory :project do
    name { Faker::App.name }
    organization
    description { "Project description" }
    iteration_start_day { 0 }
    time_zone { "UTC" }
    automatic_planning { true }
    velocity { 10 }
    initial_velocity { 10 }

    trait :archived do
      archived { true }
    end

    trait :current_iteration do
      after(:create) do |project|
        project.find_or_create_current_iteration
      end
    end

    trait :with_members do
      after(:create) do |project|
        create(:project_membership, project: project, user: create(:user))
      end
    end
  end
end
