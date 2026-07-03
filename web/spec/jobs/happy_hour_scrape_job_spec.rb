require "rails_helper"

RSpec.describe HappyHourScrapeJob, type: :job do
  it "runs the scraper for the given venue" do
    venue = create(:venue)
    scraper = instance_double(Scrapers::HappyHourScraper, call: nil)
    expect(Scrapers::HappyHourScraper).to receive(:new).with(venue).and_return(scraper)

    described_class.perform_now(venue.id)

    expect(scraper).to have_received(:call)
  end

  it "does nothing when the venue is missing" do
    expect(Scrapers::HappyHourScraper).not_to receive(:new)
    described_class.perform_now(-1)
  end

  it "skips discarded venues" do
    venue = create(:venue, discarded_at: Time.current)
    expect(Scrapers::HappyHourScraper).not_to receive(:new)
    described_class.perform_now(venue.id)
  end

  it "enqueues on the scrapers queue" do
    expect(described_class.new.queue_name).to eq("scrapers")
  end
end
