module Scrapers
  # Wraps the Google Places API (New) "searchNearby" endpoint to discover
  # bars and restaurants around a coordinate. Returns normalized Place structs;
  # persistence and dedup are the discovery scraper's job.
  class GooglePlacesClient
    ENDPOINT = "https://places.googleapis.com/v1/places:searchNearby"
    DETAILS_ENDPOINT = "https://places.googleapis.com/v1/places/%<id>s"
    INCLUDED_TYPES = %w[bar restaurant].freeze

    # Field names without the "places." prefix — used for both search (prefixed)
    # and the single-place details endpoint (unprefixed).
    FIELDS = %w[
      id displayName formattedAddress addressComponents location
      nationalPhoneNumber websiteUri
    ].freeze
    FIELD_MASK = FIELDS.map { |f| "places.#{f}" }.join(",").freeze
    DETAILS_FIELD_MASK = FIELDS.join(",").freeze

    Place = Struct.new(
      :google_place_id, :name, :address, :city, :state, :zip_code,
      :phone, :website_url, :latitude, :longitude,
      keyword_init: true
    )

    class ConfigurationError < StandardError; end

    def initialize(api_key: self.class.api_key, connection: nil)
      raise ConfigurationError, "Google Places API key not configured" if api_key.blank?

      @api_key = api_key
      @connection = connection || build_connection
    end

    # radius in meters (Google max is 50_000)
    def search_bars_and_restaurants(lat:, lng:, radius: 3000, max_results: 20)
      body = {
        includedTypes: INCLUDED_TYPES,
        maxResultCount: max_results,
        locationRestriction: {
          circle: {
            center: { latitude: lat, longitude: lng },
            radius: radius.to_f
          }
        }
      }

      response = @connection.post(ENDPOINT) do |req|
        req.headers["Content-Type"] = "application/json"
        req.headers["X-Goog-Api-Key"] = @api_key
        req.headers["X-Goog-FieldMask"] = FIELD_MASK
        req.body = JSON.generate(body)
      end

      raise "Google Places API error #{response.status}: #{response.body}" unless response.success?

      parse_places(response.body)
    end

    # Fetches one place's details (used as a fallback to fill in a missing
    # website). Returns a Place or nil.
    def place_details(place_id)
      return nil if place_id.blank?

      url = format(DETAILS_ENDPOINT, id: place_id)
      response = @connection.get(url) do |req|
        req.headers["X-Goog-Api-Key"] = @api_key
        req.headers["X-Goog-FieldMask"] = DETAILS_FIELD_MASK
      end

      return nil unless response.success?

      parse_place(JSON.parse(response.body))
    end

    def self.api_key
      Rails.application.credentials.dig(:google, :places_api_key) || ENV["GOOGLE_PLACES_API_KEY"]
    end

    private

    def parse_places(body)
      data = body.is_a?(String) ? JSON.parse(body) : body
      Array(data["places"]).map { |place| parse_place(place) }
    end

    def parse_place(place)
      components = Array(place["addressComponents"])
      Place.new(
        google_place_id: place["id"],
        name: place.dig("displayName", "text"),
        address: place["formattedAddress"],
        city: address_component(components, "locality"),
        state: address_component(components, "administrative_area_level_1", short: true),
        zip_code: address_component(components, "postal_code"),
        phone: place["nationalPhoneNumber"],
        website_url: place["websiteUri"],
        latitude: place.dig("location", "latitude"),
        longitude: place.dig("location", "longitude")
      )
    end

    # Pulls a value out of Google's addressComponents by type. State uses the
    # short name (e.g. "OH") rather than the long name ("Ohio").
    def address_component(components, type, short: false)
      component = components.find { |c| Array(c["types"]).include?(type) }
      return nil unless component

      short ? component["shortText"] : component["longText"]
    end

    def build_connection
      Faraday.new do |f|
        f.request :retry, max: 2, interval: 0.5
        f.options.timeout = 15
      end
    end
  end
end
