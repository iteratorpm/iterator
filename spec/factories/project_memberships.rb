FactoryBot.define do
  factory :project_membership do
    user
    project
    role { "member" }
  end
end
