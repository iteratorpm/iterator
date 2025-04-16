FactoryBot.define do
  factory :project do
    title { "Test Project" }
    description { "Project description" }
    association :organization
    iteration_start_day { 0 }
    project_time_zone { "UTC" }
    point_scale { "fibonacci" }
    velocity_strategy { "average" }
    initial_velocity { 10 }
    iteration_length { 1 }
    done_iterations_to_show { 4 }
  end
end
