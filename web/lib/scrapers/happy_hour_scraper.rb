module Scrapers
  # Orchestrates scraping a single venue's happy hour:
  #   1. fetch the venue website
  #   2. extract structured happy hour data with Claude
  #   3. persist it as pending records for admin review
  # Every run is logged to a ScraperRun. When nothing can be fetched or parsed,
  # the venue is flagged with needs_investigation for a human to look at.
  class HappyHourScraper
    def initialize(venue, fetcher: WebsiteFetcher.new, extractor: HappyHourExtractor.new, persister: nil)
      @venue = venue
      @fetcher = fetcher
      @extractor = extractor
      @persister = persister || HappyHourPersister.new(venue)
    end

    def call
      return record_fetch_failure("no website_url") if @venue.website_url.blank?

      result = @fetcher.fetch(@venue.website_url)
      return record_fetch_failure(result.error) if result.failed?

      extracted = @extractor.extract(result.text)

      if extracted
        persist_and_record(extracted, result)
      else
        record_not_found(result)
      end
    end

    private

    def persist_and_record(extracted, result)
      happy_hour = @persister.persist(extracted)
      return record_not_found(result) if happy_hour.nil?

      @venue.update!(scraper_status: :scraped_found, needs_investigation: false)
      log_run(
        result: :happy_hour_found,
        notes: "Created pending happy hour ##{happy_hour.id}",
        raw_data: { extracted: extracted, text_length: result.text&.length }
      )
      happy_hour
    end

    def record_not_found(result)
      @venue.update!(scraper_status: :scraped_not_found, needs_investigation: true)
      log_run(
        result: :happy_hour_not_found,
        notes: "No happy hour found; flagged for investigation",
        raw_data: { menu_links: result.menu_links, text_length: result.text&.length }
      )
      nil
    end

    def record_fetch_failure(reason)
      @venue.update!(scraper_status: :scrape_failed, needs_investigation: true)
      log_run(result: :fetch_failed, notes: reason, raw_data: { error: reason })
      nil
    end

    def log_run(result:, notes:, raw_data:)
      @venue.scraper_runs.create!(
        run_at: Time.current,
        result: result,
        notes: notes,
        raw_data: raw_data
      )
    end
  end
end
