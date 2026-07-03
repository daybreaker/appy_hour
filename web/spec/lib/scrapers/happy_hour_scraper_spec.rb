require "rails_helper"

RSpec.describe Scrapers::HappyHourScraper do
  let(:venue) { create(:venue, website_url: "https://venue.com", needs_investigation: false) }
  let(:fetcher) { instance_double(Scrapers::WebsiteFetcher) }
  let(:extractor) { instance_double(Scrapers::HappyHourExtractor) }

  def fetch_result(**attrs)
    Scrapers::WebsiteFetcher::Result.new(**attrs)
  end

  subject(:scraper) { described_class.new(venue, fetcher: fetcher, extractor: extractor) }

  context "when a happy hour is found and parsed" do
    let(:extracted) do
      { "has_happy_hour" => true, "days" => [ { "day_of_week" => 3, "start_time" => "16:00", "end_time" => "18:00" } ] }
    end

    before do
      allow(fetcher).to receive(:fetch).and_return(
        fetch_result(text: "Join us for Happy Hour 4-6pm daily", menu_links: [])
      )
      allow(extractor).to receive(:extract).and_return(extracted)
    end

    it "creates a pending happy hour" do
      expect { scraper.call }.to change { venue.happy_hours.pending.count }.by(1)
    end

    it "passes the happy-hour page text to the extractor" do
      scraper.call
      expect(extractor).to have_received(:extract).with(a_string_including("Happy Hour"))
    end

    it "marks the venue scraped_found and clears investigation" do
      scraper.call
      expect(venue.reload.scraper_status).to eq("scraped_found")
      expect(venue.needs_investigation).to be false
    end

    it "logs a happy_hour_found scraper run" do
      expect { scraper.call }.to change { venue.scraper_runs.count }.by(1)
      expect(venue.scraper_runs.last.result).to eq("happy_hour_found")
    end
  end

  context "when a page mentions happy hour but the AI can't parse deals" do
    before do
      allow(fetcher).to receive(:fetch).and_return(
        fetch_result(text: "We have a happy hour but details are on a flyer", menu_links: [])
      )
      allow(extractor).to receive(:extract).and_return(nil)
    end

    it "flags the venue for investigation" do
      scraper.call
      expect(venue.reload.needs_investigation).to be true
      expect(venue.scraper_status).to eq("scraped_not_found")
    end

    it "logs a happy_hour_not_found run and creates no happy hour" do
      expect { scraper.call }.not_to change(HappyHour, :count)
      expect(venue.scraper_runs.last.result).to eq("happy_hour_not_found")
    end
  end

  describe "keyword pre-filter (avoids wasteful AI calls)" do
    it "does not call the AI when no page mentions happy hour" do
      allow(fetcher).to receive(:fetch).and_return(
        fetch_result(text: "Dinner menu and reservations", menu_links: [])
      )
      allow(extractor).to receive(:extract)

      scraper.call

      expect(extractor).not_to have_received(:extract)
      expect(venue.scraper_runs.last.result).to eq("happy_hour_not_found")
      expect(venue.reload.needs_investigation).to be true
    end

    it "follows menu links to find the happy hour page when the homepage lacks it" do
      home = fetch_result(text: "Welcome to our restaurant", menu_links: [ "https://venue.com/specials" ])
      specials = fetch_result(text: "Happy Hour: $5 drafts 4-6pm", menu_links: [])
      allow(fetcher).to receive(:fetch).with("https://venue.com").and_return(home)
      allow(fetcher).to receive(:fetch).with("https://venue.com/specials").and_return(specials)
      allow(extractor).to receive(:extract).and_return(
        { "has_happy_hour" => true, "days" => [ { "day_of_week" => 3, "start_time" => "16:00", "end_time" => "18:00" } ] }
      )

      scraper.call

      expect(extractor).to have_received(:extract).with(a_string_including("$5 drafts"))
      expect(venue.reload.scraper_status).to eq("scraped_found")
    end

    it "follows at most MAX_LINKS_TO_FOLLOW links" do
      links = (1..10).map { |i| "https://venue.com/p#{i}" }
      home = fetch_result(text: "Welcome", menu_links: links)
      allow(fetcher).to receive(:fetch).with("https://venue.com").and_return(home)
      links.each do |l|
        allow(fetcher).to receive(:fetch).with(l).and_return(fetch_result(text: "no deals here", menu_links: []))
      end
      allow(extractor).to receive(:extract)

      scraper.call

      # 1 homepage fetch + at most MAX_LINKS_TO_FOLLOW link fetches
      expect(fetcher).to have_received(:fetch).at_most(described_class::MAX_LINKS_TO_FOLLOW + 1).times
      expect(extractor).not_to have_received(:extract)
    end
  end

  context "when the website can't be fetched" do
    before do
      allow(fetcher).to receive(:fetch).and_return(fetch_result(error: "http 500"))
    end

    it "records a fetch_failed run and flags for investigation" do
      scraper.call
      expect(venue.scraper_runs.last.result).to eq("fetch_failed")
      expect(venue.reload.scraper_status).to eq("scrape_failed")
      expect(venue.needs_investigation).to be true
    end

    it "does not call the extractor" do
      allow(extractor).to receive(:extract)
      scraper.call
      expect(extractor).not_to have_received(:extract)
    end
  end

  context "when the venue has no website" do
    let(:venue) { create(:venue, website_url: nil) }

    it "records a fetch_failed run without fetching" do
      allow(fetcher).to receive(:fetch)
      scraper.call
      expect(fetcher).not_to have_received(:fetch)
      expect(venue.scraper_runs.last.result).to eq("fetch_failed")
    end
  end
end
