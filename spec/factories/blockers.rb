FactoryBot.define do
  factory :blocker do
    story
    blocker_story { create(:story, project: story.project) }
  end
end
