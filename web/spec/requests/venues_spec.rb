require "rails_helper"

RSpec.describe "Venues", type: :request do
  describe "GET /venues" do
    it "renders without login" do
      create(:venue, name: "Alpha Bar")
      get venues_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Alpha Bar")
    end

    it "floats the signed-in user's favorites to the top" do
      user = create(:user)
      create(:venue, name: "Aaa Bar")           # alphabetically first
      faved = create(:venue, name: "Zzz Bar")   # alphabetically last, but favorited
      create(:favorite_venue, user: user, venue: faved)
      sign_in user

      get venues_path

      expect(response.body.index("Zzz Bar")).to be < response.body.index("Aaa Bar")
    end

    it "excludes discarded venues" do
      create(:venue, name: "Gone Bar", discarded_at: Time.current)
      get venues_path
      expect(response.body).not_to include("Gone Bar")
    end

    it "filters by name query" do
      create(:venue, name: "Taco Spot")
      create(:venue, name: "Burger Joint")
      get venues_path, params: { q: "Taco" }
      expect(response.body).to include("Taco Spot")
      expect(response.body).not_to include("Burger Joint")
    end
  end

  describe "GET /venues/:id" do
    it "renders the venue with approved happy hours" do
      venue = create(:venue, name: "Show Venue")
      hh = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: hh, day_of_week: 5)

      get venue_path(venue)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Show Venue")
    end

    it "returns 404 for a discarded venue" do
      venue = create(:venue, discarded_at: Time.current)
      get venue_path(venue)
      expect(response).to have_http_status(:not_found)
    end
  end
end
