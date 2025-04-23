FactoryBot.define do
  factory :iteration do
    project
    sequence(:number)
    start_date { Date.current.beginning_of_week }
    end_date { start_date + 6.days }
    velocity { 10 }

    trait :blank do
      start_date { nil }
      end_date { nil }
      number { nil }
    end

    trait :current do
      start_date { Date.current.beginning_of_week }
      end_date { start_date + 6.days }
      state { :current }
    end

    trait :past do
      state { :done }
      start_date { Date.current.beginning_of_week - 2.weeks }
      end_date { start_date + 6.days }
    end

    trait :future do
      state { :backlog }
      start_date { Date.current.beginning_of_week + 1.week }
      end_date { start_date + 6.days }
    end
  end
end
