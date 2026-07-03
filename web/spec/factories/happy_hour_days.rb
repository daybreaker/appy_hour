FactoryBot.define do
  factory :happy_hour_day do
    association :happy_hour
    day_of_week { 1 } # Monday
    start_time { "16:00" }
    end_time { "18:00" }
    specific_date { nil }
  end
end
