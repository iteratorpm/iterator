FactoryBot.define do
  factory :iteration do
    project
    sequence(:number)
    start_date { Date.current.beginning_of_week }
    end_date { start_date + 6.days }
    velocity { 10 }
    team_strength { 100 }

    trait :blank do
      start_date { nil }
      end_date { nil }
      number { nil }
    end

    trait :done do
      state { 'done' }
      start_date { Date.current - 2.weeks }
      end_date { Date.current - 1.week }
    end

    trait :current do
      state { 'current' }
      start_date { Date.current.beginning_of_week }
      end_date { Date.current.end_of_week }
    end

    trait :backlog do
      state { 'backlog' }
      start_date { Date.current + 1.week }
      end_date { Date.current + 2.weeks }
    end
  end
end
