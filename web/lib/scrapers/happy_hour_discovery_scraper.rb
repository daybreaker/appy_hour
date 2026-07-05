module Scrapers
  # NON-AI discovery. Finds bars/restaurants near a coordinate, then scans each
  # one's website for a "happy hour" mention (homepage + a few menu links, pure
  # keyword match — no LLM). A Venue is created and flagged needs_investigation
  # ONLY when a mention is found; sites with no mention are skipped entirely.
  #
  # Deliberately separate from the AI pipeline (VenueDiscoveryScraper, which
  # creates every venue, + HappyHourScraper, which uses Claude to extract deals).
  class HappyHourDiscoveryScraper
    # A site "has happy hour" if it mentions happy hour, daily specials, or
    # weekly specials.
    HAPPY_HOUR_HINT = /happy\s*-?\s*hour|daily\s+specials?|weekly\s+specials?/i
    MAX_MENU_LINKS = 6

    Result = Struct.new(:created, :scanned, :skipped_no_website, :detail_lookups, keyword_init: true)

    def initialize(places_client: GooglePlacesClient.new, fetcher: WebsiteFetcher.new, max_detail_lookups: 25)
      @places_client = places_client
      @fetcher = fetcher
      @max_detail_lookups = max_detail_lookups
    end

    def call(lat:, lng:, radius: 1500, neighborhood: nil, max_results: 20)
      places = @places_client.search_bars_and_restaurants(
        lat: lat, lng: lng, radius: radius, max_results: max_results
      )

      created = []
      detail_lookups = 0
      skipped_no_website = 0

      places.each do |place|
        # Fill in a missing website via a place-details lookup (capped).
        if place.website_url.blank? && detail_lookups < @max_detail_lookups
          detail_lookups += 1
          detailed = @places_client.place_details(place.google_place_id)
          place = detailed if detailed&.website_url.present?
        end

        if place.website_url.blank?
          skipped_no_website += 1
          next
        end

        scan = scan_site(place.website_url)
        next unless scan[:mentions]

        created << create_flagged_venue(place, neighborhood, scan)
      end

      Result.new(
        created: created, scanned: places.size,
        skipped_no_website: skipped_no_website, detail_lookups: detail_lookups
      )
    end

    private

    # Homepage first, then up to a few menu links. Returns whether any page
    # mentions happy hour, plus detected social links and the matching URL.
    def scan_site(url)
      home = @fetcher.fetch(url)
      return { mentions: false, social_links: [], source: nil } if home.failed?

      return { mentions: true, social_links: home.social_links, source: url } if mentions?(home.text)

      home.menu_links.first(MAX_MENU_LINKS).each do |link|
        page = @fetcher.fetch(link)
        next if page.failed?
        return { mentions: true, social_links: home.social_links, source: link } if mentions?(page.text)
      end

      { mentions: false, social_links: home.social_links, source: nil }
    end

    def mentions?(text)
      text.to_s.match?(HAPPY_HOUR_HINT)
    end

    def create_flagged_venue(place, neighborhood, scan)
      venue = Venue.find_or_initialize_by(google_place_id: place.google_place_id)
      venue.assign_attributes(
        name: place.name,
        address: place.address,
        city: place.city.presence || venue.city,
        state: place.state.presence || venue.state,
        zip_code: place.zip_code.presence || venue.zip_code,
        phone: place.phone.presence || venue.phone,
        website_url: place.website_url.presence || venue.website_url,
        needs_investigation: true,
        scraper_status: :scraped_found
      )
      venue.neighborhood ||= neighborhood
      set_location(venue, place)
      venue.save!

      save_social_links(venue, scan[:social_links])
      venue.scraper_runs.create!(
        run_at: Time.current,
        result: :happy_hour_found,
        notes: "Non-AI discovery: 'happy hour' found at #{scan[:source]}. Flagged for manual review.",
        raw_data: { source: scan[:source] }
      )
      venue
    end

    def set_location(venue, place)
      return if place.latitude.blank? || place.longitude.blank?

      venue.lonlat = "POINT(#{place.longitude} #{place.latitude})"
    end

    def save_social_links(venue, links)
      Array(links).each do |link|
        record = venue.social_links.find_or_initialize_by(url: link.url)
        record.platform = link.platform
        record.save
      end
    end
  end
end
