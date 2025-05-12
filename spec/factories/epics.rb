FactoryBot.define do
  factory :epic do
    name { "MyString" }
    description { "MyText" }
    project
    external_link { "MyString" }

    trait :label do
      after :create do |epic|
        create :label, epic: epic, project: epic.project
      end
    end
  end
end
