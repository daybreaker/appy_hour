FactoryBot.define do
  factory :scraper_run do
    venue { nil }
    run_at { "2026-07-03 10:48:38" }
    result { 1 }
    notes { "MyText" }
  end
end
