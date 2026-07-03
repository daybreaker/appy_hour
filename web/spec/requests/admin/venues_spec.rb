require "rails_helper"

RSpec.describe "Admin::Venues", type: :request do
  let(:admin) { create(:user, role: :admin) }

  before { sign_in admin }

  describe "GET /admin/venues" do
    it "lists all kept venues by default" do
      create(:venue, name: "Alpha Bar")
      create(:venue, name: "Beta Grill")
      get admin_venues_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Alpha Bar")
      expect(response.body).to include("Beta Grill")
    end

    it "filters to venues needing investigation" do
      create(:venue, needs_investigation: true, name: "Flagged Bar")
      create(:venue, needs_investigation: false, name: "Clean Bar")
      get admin_venues_path(filter: "investigation")
      expect(response.body).to include("Flagged Bar")
      expect(response.body).not_to include("Clean Bar")
    end

    it "searches by name" do
      create(:venue, name: "Taco Spot")
      create(:venue, name: "Burger Joint")
      get admin_venues_path(q: "Taco")
      expect(response.body).to include("Taco Spot")
      expect(response.body).not_to include("Burger Joint")
    end
  end

  describe "GET /admin/venues/:id" do
    it "renders the venue detail" do
      venue = create(:venue, name: "Detail Bar")
      get admin_venue_path(venue)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Detail Bar")
    end
  end

  describe "GET new and edit forms" do
    it "renders the new form" do
      get new_admin_venue_path
      expect(response).to have_http_status(:ok)
    end

    it "renders the edit form" do
      venue = create(:venue)
      get edit_admin_venue_path(venue)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/venues" do
    let(:neighborhood) { create(:neighborhood) }

    it "creates a venue" do
      expect {
        post admin_venues_path, params: { venue: {
          name: "New Spot", address: "1 Main", city: "Cleveland", zip_code: "44113",
          neighborhood_id: neighborhood.id
        } }
      }.to change(Venue, :count).by(1)
      expect(response).to redirect_to(admin_venue_path(Venue.last))
    end

    it "sets PostGIS coordinates when lat/lng given" do
      post admin_venues_path, params: { venue: {
        name: "Geo Bar", latitude: "41.4993", longitude: "-81.6944"
      } }
      venue = Venue.last
      expect(venue.latitude).to be_within(0.001).of(41.4993)
      expect(venue.longitude).to be_within(0.001).of(-81.6944)
    end

    it "re-renders on invalid input" do
      post admin_venues_path, params: { venue: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(Venue.count).to eq(0)
    end
  end

  describe "PATCH /admin/venues/:id" do
    let!(:venue) { create(:venue, name: "Old Name") }

    it "updates venue attributes" do
      patch admin_venue_path(venue), params: { venue: { name: "New Name", phone: "216-555-0000" } }
      expect(venue.reload.name).to eq("New Name")
      expect(venue.phone).to eq("216-555-0000")
      expect(response).to redirect_to(admin_venue_path(venue))
    end
  end

  describe "DELETE /admin/venues/:id" do
    it "soft-deletes (discards) the venue" do
      venue = create(:venue)
      delete admin_venue_path(venue)
      expect(venue.reload.discarded?).to be true
    end
  end

  describe "PATCH /admin/venues/:id/clear_investigation" do
    let!(:venue) { create(:venue, needs_investigation: true) }

    it "clears the needs_investigation flag" do
      patch clear_investigation_admin_venue_path(venue)
      expect(venue.reload.needs_investigation).to be false
    end

    it "redirects back to the investigation queue" do
      patch clear_investigation_admin_venue_path(venue)
      expect(response).to redirect_to(admin_venues_path(filter: "investigation"))
    end
  end
end
