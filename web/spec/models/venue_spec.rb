require "rails_helper"

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
RSpec.describe Venue, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:neighborhood).optional }
    it { is_expected.to have_many(:happy_hours).dependent(:destroy) }
    it { is_expected.to have_many(:favorite_venues).dependent(:destroy) }
    it { is_expected.to have_many(:ratings) }
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:reports) }
    it { is_expected.to have_many(:scraper_runs).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to define_enum_for(:scraper_status).with_values(not_scraped: 0, scraped_found: 1, scraped_not_found: 2, scrape_failed: 3) }
  end

  describe "soft deletes" do
    it "is not discarded by default" do
      venue = create(:venue)
      expect(venue.discarded?).to be false
    end

    it "is excluded from the default scope after discard" do
      venue = create(:venue)
      venue.discard
      expect(Venue.kept).not_to include(venue)
    end
  end

  describe ".needs_investigation" do
    it "returns only venues flagged for investigation" do
      flagged = create(:venue, needs_investigation: true)
      create(:venue, needs_investigation: false)
      expect(Venue.needs_investigation).to contain_exactly(flagged)
    end
  end

  describe ".with_happy_hours_on" do
    it "returns venues with an approved happy hour on the given day of week" do
      venue = create(:venue)
      happy_hour = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 3) # Wednesday

      expect(Venue.with_happy_hours_on(3)).to contain_exactly(venue)
    end

    it "excludes venues whose happy hour is on a different day" do
      venue = create(:venue)
      happy_hour = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 1) # Monday

      expect(Venue.with_happy_hours_on(3)).to be_empty
    end

    it "excludes venues whose happy hour is not approved" do
      venue = create(:venue)
      happy_hour = create(:happy_hour, status: :pending, venue: venue)
      create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 3)

      expect(Venue.with_happy_hours_on(3)).to be_empty
    end

    it "excludes discarded venues" do
      venue = create(:venue, discarded_at: Time.current)
      happy_hour = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 3)

      expect(Venue.with_happy_hours_on(3)).to be_empty
    end

    it "returns a venue only once even with multiple matching days" do
      venue = create(:venue)
      happy_hour = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 3, start_time: "16:00", end_time: "18:00")
      hh2 = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: hh2, day_of_week: 3, start_time: "20:00", end_time: "22:00")

      expect(Venue.with_happy_hours_on(3).count).to eq(1)
    end
  end

  describe "#latitude and #longitude" do
    it "returns nil when lonlat is not set" do
      venue = build(:venue)
      expect(venue.latitude).to be_nil
      expect(venue.longitude).to be_nil
    end
  end
end
