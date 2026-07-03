require "rails_helper"

RSpec.describe Scrapers::GooglePlacesClient do
  let(:api_response) do
    {
      "places" => [
        {
          "id" => "PLACE123",
          "displayName" => { "text" => "Great Lakes Brewing" },
          "formattedAddress" => "2516 Market Ave, Cleveland, OH 44113",
          "addressComponents" => [
            { "longText" => "Cleveland", "shortText" => "Cleveland", "types" => [ "locality", "political" ] },
            { "longText" => "Ohio", "shortText" => "OH", "types" => [ "administrative_area_level_1", "political" ] },
            { "longText" => "44113", "shortText" => "44113", "types" => [ "postal_code" ] }
          ],
          "nationalPhoneNumber" => "(216) 771-4404",
          "websiteUri" => "https://greatlakesbrewing.com",
          "location" => { "latitude" => 41.4846, "longitude" => -81.7027 }
        }
      ]
    }
  end

  describe "#search_bars_and_restaurants" do
    it "posts to the Places API and returns normalized places" do
      stub = stub_request(:post, described_class::ENDPOINT)
        .with(headers: { "X-Goog-Api-Key" => "test-key" })
        .to_return(status: 200, body: JSON.generate(api_response),
                   headers: { "Content-Type" => "application/json" })

      client = described_class.new(api_key: "test-key")
      places = client.search_bars_and_restaurants(lat: 41.49, lng: -81.69, radius: 3000)

      expect(stub).to have_been_requested
      place = places.first
      expect(place.google_place_id).to eq("PLACE123")
      expect(place.name).to eq("Great Lakes Brewing")
      expect(place.website_url).to eq("https://greatlakesbrewing.com")
      expect(place.latitude).to eq(41.4846)
      expect(place.city).to eq("Cleveland")
      expect(place.state).to eq("OH")
      expect(place.zip_code).to eq("44113")
    end

    it "raises on a non-success response" do
      stub_request(:post, described_class::ENDPOINT)
        .to_return(status: 403, body: "denied")

      client = described_class.new(api_key: "test-key")
      expect {
        client.search_bars_and_restaurants(lat: 1, lng: 2)
      }.to raise_error(/Google Places API error 403/)
    end
  end

  describe "configuration" do
    it "raises when no api key is available" do
      expect {
        described_class.new(api_key: nil)
      }.to raise_error(Scrapers::GooglePlacesClient::ConfigurationError)
    end
  end
end
