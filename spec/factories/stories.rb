FactoryBot.define do
  factory :story do
    title { "MyString" }
    description { "MyText" }
    story_type { 1 }
    status { 1 }
    points { 1 }
    project { nil }
    epic { nil }
    iteration { nil }
    assignee { nil }
  end
end
