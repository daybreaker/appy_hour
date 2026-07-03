module Scrapers
  # Orchestrates scraping a single venue's happy hour:
  #   1. fetch the venue website
  #   2. extract structured happy hour data with Claude
  #   3. persist it as pending records for admin review
  # Every run is logged to a ScraperRun. When nothing can be fetched or parsed,
  # the venue is flagged with needs_investigation for a human to look at.
  class HappyHourScraper
    # Cheap keyword pre-filter: only escalate to the (paid) AI parse when a page
    # actually mentions happy hour. Matches "happy hour", "happyhour", "happy-hour".
    HAPPY_HOUR_HINT = /happy\s*-?\s*hour/i

    # Cap how many menu/happy-hour links we'll follow looking for the details.
    MAX_LINKS_TO_FOLLOW = 3

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

      # Capture social links regardless of happy hour outcome — they help an
      # admin investigate when no menu is found on the site.
      save_social_links(result.social_links)

      # Pre-filter with Nokogiri-extracted text before spending an AI call.
      candidate_text = happy_hour_candidate_text(result)
      return record_not_found(result) if candidate_text.blank?

      extracted = @extractor.extract(candidate_text)

      if extracted
        persist_and_record(extracted, result)
      else
        record_not_found(result)
      end
    end

    private

    # Returns the combined text of pages that mention happy hour (the homepage
    # and/or a few followed menu links), or nil if none do — in which case the
    # AI is never called.
    def happy_hour_candidate_text(result)
      texts = []
      texts << result.text if mentions_happy_hour?(result.text)

      result.menu_links.first(MAX_LINKS_TO_FOLLOW).each do |link|
        page = @fetcher.fetch(link)
        next if page.failed?

        texts << page.text if mentions_happy_hour?(page.text)
      end

      texts.presence&.join("\n\n")
    end

    def mentions_happy_hour?(text)
      text.to_s.match?(HAPPY_HOUR_HINT)
    end

    def save_social_links(links)
      Array(links).each do |link|
        record = @venue.social_links.find_or_initialize_by(url: link.url)
        record.platform = link.platform
        record.save
      end
    end

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
