namespace :scrape do
  desc "Non-AI happy-hour discovery near an address. " \
       "Usage: rake 'scrape:happy_hours[3804 Franklin Blvd Cleveland OH 44113,1500]'"
  task :happy_hours, [ :address, :radius ] => :environment do |_t, args|
    address = args[:address] or abort "Provide an address: rake 'scrape:happy_hours[ADDRESS,RADIUS]'"
    radius  = (args[:radius] || 1500).to_i

    coords = Geocoder.coordinates(address)
    abort "Could not geocode #{address.inspect}" if coords.blank?
    lat, lng = coords
    puts "Geocoded #{address} -> #{lat}, #{lng} (radius #{radius}m)"

    result = Scrapers::HappyHourDiscoveryScraper.new.call(lat: lat, lng: lng, radius: radius)

    puts "Scanned #{result.scanned} places, #{result.detail_lookups} detail lookups, " \
         "#{result.skipped_no_website} skipped (no website)."
    puts "Created #{result.created.size} venue(s) flagged for investigation:"
    result.created.each { |v| puts "  • #{v.name} — #{v.website_url}" }
  end
end
