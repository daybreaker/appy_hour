module Scrapers
  # Discovers bars and restaurants around a coordinate via Google Places and
  # upserts them as Venue records (deduped on google_place_id). Returns the
  # venues that were newly created so the caller can enqueue happy hour scrapes.
  class VenueDiscoveryScraper
    def initialize(client: GooglePlacesClient.new)
      @client = client
    end

    def call(lat:, lng:, radius: 3000, neighborhood: nil)
      places = @client.search_bars_and_restaurants(lat: lat, lng: lng, radius: radius)

      places.filter_map { |place| upsert_venue(place, neighborhood) }
    end

    private

    # Returns the venue if it was newly created, nil if it already existed.
    def upsert_venue(place, neighborhood)
      return nil if place.google_place_id.blank?

      venue = Venue.find_or_initialize_by(google_place_id: place.google_place_id)
      newly_created = venue.new_record?

      venue.assign_attributes(
        name: place.name,
        address: place.address,
        phone: place.phone.presence || venue.phone,
        website_url: place.website_url.presence || venue.website_url
      )
      venue.neighborhood ||= neighborhood
      set_location(venue, place)
      venue.save!

      newly_created ? venue : nil
    end

    def set_location(venue, place)
      return if place.latitude.blank? || place.longitude.blank?

      venue.lonlat = "POINT(#{place.longitude} #{place.latitude})"
    end
  end
end
