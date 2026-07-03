require "rails_helper"

RSpec.describe Scrapers::VenueDiscoveryScraper do
  let(:client) { instance_double(Scrapers::GooglePlacesClient) }
  subject(:scraper) { described_class.new(client: client) }

  def place(id:, name:, **attrs)
    Scrapers::GooglePlacesClient::Place.new(
      google_place_id: id, name: name,
      address: attrs[:address] || "123 St", phone: attrs[:phone],
      website_url: attrs[:website_url], latitude: attrs[:lat] || 41.5, longitude: attrs[:lng] || -81.7
    )
  end

  describe "#call" do
    it "creates venues for discovered places" do
      allow(client).to receive(:search_bars_and_restaurants).and_return([
        place(id: "A1", name: "Alpha Bar", website_url: "https://alpha.com"),
        place(id: "B2", name: "Beta Grill")
      ])

      expect {
        scraper.call(lat: 41.5, lng: -81.7)
      }.to change(Venue, :count).by(2)
    end

    it "returns only newly created venues" do
      create(:venue, google_place_id: "A1", name: "Existing")
      allow(client).to receive(:search_bars_and_restaurants).and_return([
        place(id: "A1", name: "Alpha Bar"),
        place(id: "B2", name: "Beta Grill")
      ])

      new_venues = scraper.call(lat: 41.5, lng: -81.7)

      expect(new_venues.map(&:name)).to eq([ "Beta Grill" ])
    end

    it "is idempotent — re-running does not duplicate venues" do
      allow(client).to receive(:search_bars_and_restaurants).and_return([
        place(id: "A1", name: "Alpha Bar")
      ])

      scraper.call(lat: 41.5, lng: -81.7)
      expect {
        scraper.call(lat: 41.5, lng: -81.7)
      }.not_to change(Venue, :count)
    end

    it "assigns the neighborhood to newly created venues" do
      neighborhood = create(:neighborhood)
      allow(client).to receive(:search_bars_and_restaurants).and_return([
        place(id: "A1", name: "Alpha Bar")
      ])

      scraper.call(lat: 41.5, lng: -81.7, neighborhood: neighborhood)
      expect(Venue.find_by(google_place_id: "A1").neighborhood).to eq(neighborhood)
    end

    it "stores the location as a PostGIS point" do
      allow(client).to receive(:search_bars_and_restaurants).and_return([
        place(id: "A1", name: "Alpha Bar", lat: 41.4993, lng: -81.6944)
      ])

      scraper.call(lat: 41.5, lng: -81.7)
      venue = Venue.find_by(google_place_id: "A1")
      expect(venue.latitude).to be_within(0.001).of(41.4993)
      expect(venue.longitude).to be_within(0.001).of(-81.6944)
    end
  end
end
