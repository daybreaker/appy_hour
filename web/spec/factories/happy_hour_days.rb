FactoryBot.define do
  factory :happy_hour_day do
    happy_hour { nil }
    day_of_week { 1 }
    start_time { "2026-07-03 10:48:27" }
    end_time { "2026-07-03 10:48:27" }
    specific_date { "2026-07-03" }
  end
end
