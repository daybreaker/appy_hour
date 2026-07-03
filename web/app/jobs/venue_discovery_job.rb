# Discovers venues around a coordinate, then enqueues a happy hour scrape for
# each newly discovered venue.
class VenueDiscoveryJob < ApplicationJob
  queue_as :scrapers

  def perform(lat:, lng:, radius: 3000, neighborhood_id: nil)
    neighborhood = neighborhood_id && Neighborhood.find_by(id: neighborhood_id)

    new_venues = Scrapers::VenueDiscoveryScraper.new.call(
      lat: lat, lng: lng, radius: radius, neighborhood: neighborhood
    )

    new_venues.each { |venue| HappyHourScrapeJob.perform_later(venue.id) }
  end
end
