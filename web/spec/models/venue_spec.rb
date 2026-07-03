require "rails_helper"

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

  describe "#latitude and #longitude" do
    it "returns nil when lonlat is not set" do
      venue = build(:venue)
      expect(venue.latitude).to be_nil
      expect(venue.longitude).to be_nil
    end
  end
end
