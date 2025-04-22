FactoryBot.define do
  factory :membership do
    user
    organization
    role { 'member' }
    project_creator { false }
  end
end
