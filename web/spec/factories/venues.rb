FactoryBot.define do
  factory :venue do
    sequence(:name) { |n| "Venue #{n}" }
    address { "123 Main St" }
    city { "Cleveland" }
    state { "OH" }
    zip_code { "44113" }
    phone { "216-555-0100" }
    website_url { "https://example.com" }
    neighborhood { nil }
    needs_investigation { false }
    scraper_status { :not_scraped }
    discarded_at { nil }
  end
end
