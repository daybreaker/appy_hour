require "rails_helper"

RSpec.describe VenueDiscoveryJob, type: :job do
  include ActiveJob::TestHelper

  it "discovers venues and enqueues a scrape for each new one" do
    v1 = create(:venue)
    v2 = create(:venue)
    scraper = instance_double(Scrapers::VenueDiscoveryScraper, call: [ v1, v2 ])
    allow(Scrapers::VenueDiscoveryScraper).to receive(:new).and_return(scraper)

    expect {
      described_class.perform_now(lat: 41.5, lng: -81.7)
    }.to have_enqueued_job(HappyHourScrapeJob).with(v1.id)
      .and have_enqueued_job(HappyHourScrapeJob).with(v2.id)
  end

  it "passes the neighborhood through to the scraper" do
    neighborhood = create(:neighborhood)
    scraper = instance_double(Scrapers::VenueDiscoveryScraper, call: [])
    expect(Scrapers::VenueDiscoveryScraper).to receive(:new).and_return(scraper)
    expect(scraper).to receive(:call).with(hash_including(neighborhood: neighborhood))

    described_class.perform_now(lat: 41.5, lng: -81.7, neighborhood_id: neighborhood.id)
  end
end
