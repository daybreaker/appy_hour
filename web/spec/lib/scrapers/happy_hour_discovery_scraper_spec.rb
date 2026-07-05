require "rails_helper"

RSpec.describe Scrapers::HappyHourDiscoveryScraper do
  let(:places_client) { instance_double(Scrapers::GooglePlacesClient) }
  let(:fetcher) { instance_double(Scrapers::WebsiteFetcher) }
  subject(:scraper) { described_class.new(places_client: places_client, fetcher: fetcher) }

  def place(id:, name:, website: nil, **attrs)
    Scrapers::GooglePlacesClient::Place.new(
      google_place_id: id, name: name, address: attrs[:address] || "1 Main St",
      city: "Cleveland", state: "OH", zip_code: "44113",
      phone: nil, website_url: website, latitude: 41.48, longitude: -81.71
    )
  end

  def fetch_result(**attrs)
    Scrapers::WebsiteFetcher::Result.new(social_links: [], menu_links: [], **attrs)
  end

  it "creates ONLY venues whose site mentions happy hour, flagged for investigation" do
    allow(places_client).to receive(:search_bars_and_restaurants).and_return([
      place(id: "A1", name: "Happy Bar", website: "https://happybar.com"),
      place(id: "B2", name: "Plain Diner", website: "https://plaindiner.com")
    ])
    allow(fetcher).to receive(:fetch).with("https://happybar.com")
      .and_return(fetch_result(text: "Join us for Happy Hour 4-6"))
    allow(fetcher).to receive(:fetch).with("https://plaindiner.com")
      .and_return(fetch_result(text: "Fine dining, reservations recommended"))

    result = scraper.call(lat: 41.48, lng: -81.71)

    expect(result.created.map(&:name)).to eq([ "Happy Bar" ])
    expect(Venue.pluck(:name)).to eq([ "Happy Bar" ]) # Plain Diner NOT created
    venue = result.created.first
    expect(venue.needs_investigation).to be true
    expect(venue.scraper_status).to eq("scraped_found")
    expect(venue.scraper_runs.last.result).to eq("happy_hour_found")
  end

  it "follows menu links when the homepage doesn't mention happy hour" do
    allow(places_client).to receive(:search_bars_and_restaurants).and_return([
      place(id: "A1", name: "Menu Bar", website: "https://menubar.com")
    ])
    allow(fetcher).to receive(:fetch).with("https://menubar.com")
      .and_return(fetch_result(text: "Welcome", menu_links: [ "https://menubar.com/specials" ]))
    allow(fetcher).to receive(:fetch).with("https://menubar.com/specials")
      .and_return(fetch_result(text: "Happy Hour $5 drafts"))

    result = scraper.call(lat: 41.48, lng: -81.71)
    expect(result.created.map(&:name)).to eq([ "Menu Bar" ])
  end

  it "looks up place details to fill a missing website (capped)" do
    allow(places_client).to receive(:search_bars_and_restaurants).and_return([
      place(id: "A1", name: "No Web Bar", website: nil)
    ])
    allow(places_client).to receive(:place_details).with("A1")
      .and_return(place(id: "A1", name: "No Web Bar", website: "https://nowebbar.com"))
    allow(fetcher).to receive(:fetch).with("https://nowebbar.com")
      .and_return(fetch_result(text: "Happy hour daily"))

    result = scraper.call(lat: 41.48, lng: -81.71)
    expect(result.detail_lookups).to eq(1)
    expect(result.created.map(&:name)).to eq([ "No Web Bar" ])
  end

  it "skips places with no website (and never calls the fetcher for them)" do
    allow(places_client).to receive(:search_bars_and_restaurants).and_return([
      place(id: "A1", name: "Websiteless", website: nil)
    ])
    allow(places_client).to receive(:place_details).with("A1").and_return(nil)

    result = scraper.call(lat: 41.48, lng: -81.71)
    expect(result.skipped_no_website).to eq(1)
    expect(result.created).to be_empty
    expect(Venue.count).to eq(0)
  end

  it "is idempotent on google_place_id" do
    allow(places_client).to receive(:search_bars_and_restaurants).and_return([
      place(id: "A1", name: "Happy Bar", website: "https://happybar.com")
    ])
    allow(fetcher).to receive(:fetch).and_return(fetch_result(text: "happy hour"))

    scraper.call(lat: 41.48, lng: -81.71)
    expect { scraper.call(lat: 41.48, lng: -81.71) }.not_to change(Venue, :count)
  end
end
