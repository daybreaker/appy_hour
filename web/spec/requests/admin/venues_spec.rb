require "rails_helper"

RSpec.describe "Admin::Venues", type: :request do
  let(:admin) { create(:user, role: :admin) }

  before { sign_in admin }

  describe "GET /admin/venues" do
    it "lists only venues needing investigation" do
      flagged = create(:venue, needs_investigation: true, name: "Flagged Bar")
      clean = create(:venue, needs_investigation: false, name: "Clean Bar")

      get admin_venues_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Flagged Bar")
      expect(response.body).not_to include("Clean Bar")
    end
  end

  describe "PATCH /admin/venues/:id" do
    let!(:venue) { create(:venue, needs_investigation: true) }

    it "clears the needs_investigation flag" do
      patch admin_venue_path(venue), params: { clear_investigation: "1" }
      expect(venue.reload.needs_investigation).to be false
    end

    it "redirects back to the venues queue" do
      patch admin_venue_path(venue), params: { clear_investigation: "1" }
      expect(response).to redirect_to(admin_venues_path)
    end
  end
end
