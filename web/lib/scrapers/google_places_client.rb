module Scrapers
  # Wraps the Google Places API (New) "searchNearby" endpoint to discover
  # bars and restaurants around a coordinate. Returns normalized Place structs;
  # persistence and dedup are the discovery scraper's job.
  class GooglePlacesClient
    ENDPOINT = "https://places.googleapis.com/v1/places:searchNearby"
    INCLUDED_TYPES = %w[bar restaurant].freeze
    FIELD_MASK = [
      "places.id",
      "places.displayName",
      "places.formattedAddress",
      "places.location",
      "places.nationalPhoneNumber",
      "places.websiteUri"
    ].join(",").freeze

    Place = Struct.new(
      :google_place_id, :name, :address, :phone, :website_url, :latitude, :longitude,
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

    def self.api_key
      Rails.application.credentials.dig(:google, :places_api_key) || ENV["GOOGLE_PLACES_API_KEY"]
    end

    private

    def parse_places(body)
      data = body.is_a?(String) ? JSON.parse(body) : body
      Array(data["places"]).map do |place|
        Place.new(
          google_place_id: place["id"],
          name: place.dig("displayName", "text"),
          address: place["formattedAddress"],
          phone: place["nationalPhoneNumber"],
          website_url: place["websiteUri"],
          latitude: place.dig("location", "latitude"),
          longitude: place.dig("location", "longitude")
        )
      end
    end

    def build_connection
      Faraday.new do |f|
        f.request :retry, max: 2, interval: 0.5
        f.options.timeout = 15
      end
    end
  end
end
