FactoryBot.define do
  factory :remote_parse_goal do
    genre

    order { 'desc' }
    limit { 2 }
    date { Time.zone.now + 1.day }
    wday { 2 }
    hour { 23 }
    min { 0 }
    weeks_delay { 0 }

    trait :with_actual_date do
      date { Time.zone.now - 1.day }
    end
  end
end
