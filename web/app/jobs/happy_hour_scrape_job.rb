# Scrapes a single venue's happy hour. Enqueued per-venue by
# VenueDiscoveryJob or scheduled in bulk for re-scraping.
class HappyHourScrapeJob < ApplicationJob
  queue_as :scrapers

  discard_on ActiveJob::DeserializationError

  def perform(venue_id)
    venue = Venue.kept.find_by(id: venue_id)
    return if venue.nil?

    Scrapers::HappyHourScraper.new(venue).call
  end
end
