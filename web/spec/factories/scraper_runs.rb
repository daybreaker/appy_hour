FactoryBot.define do
  factory :scraper_run do
    association :venue
    run_at { Time.current }
    result { :happy_hour_found }
    notes { "" }
    raw_data { {} }
  end
end
