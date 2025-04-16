FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@example.com" }
    username { "user#{rand(1..10000)}" }
    password { "password" }
    confirmed_at { Time.now }

    trait :unconfirmed do
    confirmed_at { nil }
    end
  end
end
