FactoryBot.define do
  factory :user do
    username { Faker::Name.unique.name }
    name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    password { "password" }
    confirmed_at { Time.now }

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
