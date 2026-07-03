require "rails_helper"

RSpec.describe "Api::V1::Venues", type: :request do
  describe "GET /api/v1/venues" do
    it "is publicly accessible and returns paginated data" do
      create(:venue, name: "Alpha")
      get "/api/v1/venues"

      expect(response).to have_http_status(:ok)
      expect(json["data"]).to be_an(Array)
      expect(json["meta"]).to include("page", "total_pages", "count")
    end

    it "includes the state field" do
      create(:venue, name: "Alpha", state: "OH")
      get "/api/v1/venues"
      expect(json["data"].first["state"]).to eq("OH")
    end

    it "excludes discarded venues" do
      create(:venue, name: "Gone", discarded_at: Time.current)
      get "/api/v1/venues"
      names = json["data"].map { |v| v["name"] }
      expect(names).not_to include("Gone")
    end

    it "filters by day of week" do
      venue = create(:venue, name: "Wed Bar")
      hh = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: hh, day_of_week: 3)

      other = create(:venue, name: "Mon Bar")
      hh2 = create(:happy_hour, :approved, venue: other)
      create(:happy_hour_day, happy_hour: hh2, day_of_week: 1)

      get "/api/v1/venues", params: { day: 3 }

      names = json["data"].map { |v| v["name"] }
      expect(names).to include("Wed Bar")
      expect(names).not_to include("Mon Bar")
    end

    it "filters by neighborhood" do
      hood = create(:neighborhood, name: "Ohio City")
      create(:venue, name: "In Hood", neighborhood: hood)
      create(:venue, name: "Out Hood")

      get "/api/v1/venues", params: { neighborhood_id: hood.id }

      names = json["data"].map { |v| v["name"] }
      expect(names).to eq([ "In Hood" ])
    end
  end

  describe "GET /api/v1/venues/:id" do
    it "returns the venue with its approved happy hours (detail view)" do
      venue = create(:venue, name: "Detail Bar")
      hh = create(:happy_hour, :approved, venue: venue, notes: "Cheap beer")
      day = create(:happy_hour_day, happy_hour: hh, day_of_week: 5, start_time: "16:00", end_time: "18:00")
      create(:happy_hour_generic, happy_hour_day: day, applies_to: "drafts", discount_type: :percentage, discount_value: 20)

      get "/api/v1/venues/#{venue.id}"

      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Detail Bar")
      expect(json["happy_hours"].first["notes"]).to eq("Cheap beer")
      expect(json["happy_hours"].first).to have_key("source_url")
      expect(json["happy_hours"].first).to have_key("link")
      day_json = json["happy_hours"].first["days"].first
      expect(day_json["day_name"]).to eq("Friday")
      expect(day_json["start_time"]).to eq("16:00")
      expect(day_json["generic_deals"].first["applies_to"]).to eq("drafts")
    end

    it "includes the venue's social links in the detail view" do
      venue = create(:venue)
      create(:social_link, venue: venue, platform: :instagram, url: "https://instagram.com/detailbar")

      get "/api/v1/venues/#{venue.id}"

      expect(json["social_links"].first).to include("platform" => "instagram", "url" => "https://instagram.com/detailbar")
    end

    it "omits non-approved happy hours" do
      venue = create(:venue)
      create(:happy_hour, status: :pending, venue: venue, notes: "Hidden")

      get "/api/v1/venues/#{venue.id}"
      expect(json["happy_hours"]).to be_empty
    end

    it "returns 404 for a discarded venue" do
      venue = create(:venue, discarded_at: Time.current)
      get "/api/v1/venues/#{venue.id}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
