namespace :scrape do
  desc "Non-AI happy-hour discovery near an address. Pass 'deep' as the 3rd arg " \
       "to use headless Chrome (handles JS sites, age gates, splash pages, PDFs). " \
       "Usage: rake 'scrape:happy_hours[3804 Franklin Blvd Cleveland OH 44113,1500,deep]'"
  task :happy_hours, [ :address, :radius, :mode ] => :environment do |_t, args|
    address = args[:address] or abort "Provide an address: rake 'scrape:happy_hours[ADDRESS,RADIUS,MODE]'"
    radius  = (args[:radius] || 1500).to_i
    deep    = args[:mode].to_s.casecmp?("deep")

    coords = Geocoder.coordinates(address)
    abort "Could not geocode #{address.inspect}" if coords.blank?
    lat, lng = coords
    puts "Geocoded #{address} -> #{lat}, #{lng} (radius #{radius}m, #{deep ? 'headless' : 'plain HTTP'})"

    fetcher = deep ? Scrapers::BrowserFetcher.new : Scrapers::WebsiteFetcher.new
    begin
      result = Scrapers::HappyHourDiscoveryScraper.new(fetcher: fetcher).call(lat: lat, lng: lng, radius: radius)

      puts "Scanned #{result.scanned} places, #{result.detail_lookups} detail lookups, " \
           "#{result.skipped_no_website} skipped (no website)."
      puts "Created #{result.created.size} venue(s) flagged for investigation:"
      result.created.each { |v| puts "  • #{v.name} — #{v.website_url}" }
    ensure
      fetcher.close if fetcher.respond_to?(:close)
    end
  end
end
