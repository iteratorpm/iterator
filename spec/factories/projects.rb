FactoryBot.define do
  factory :project do
    name { Faker::App.name }
    organization
    description { "Project description" }
    iteration_start_day { 0 }
    time_zone { :eastern }
  end
end
