# == Schema Information
#
# Table name: venues
#
#  id                  :bigint           not null, primary key
#  address             :string
#  city                :string
#  discarded_at        :datetime
#  lonlat              :geography        point, 4326
#  name                :string           not null
#  needs_investigation :boolean          default(FALSE), not null
#  phone               :string
#  scraper_status      :integer          default("not_scraped"), not null
#  state               :string
#  website_url         :string
#  zip_code            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  google_place_id     :string
#  neighborhood_id     :bigint
#
# Indexes
#
#  index_venues_on_city                 (city)
#  index_venues_on_discarded_at         (discarded_at)
#  index_venues_on_google_place_id      (google_place_id) UNIQUE
#  index_venues_on_lonlat               (lonlat) USING gist
#  index_venues_on_needs_investigation  (needs_investigation)
#  index_venues_on_neighborhood_id      (neighborhood_id)
#  index_venues_on_zip_code             (zip_code)
#
# Foreign Keys
#
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#
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
