require "rails_helper"

RSpec.describe "Api::V1::Favorites", type: :request do
  let(:user) { create(:user) }
  let(:venue) { create(:venue) }

  describe "POST /api/v1/venues/:venue_id/favorite" do
    it "requires auth" do
      post "/api/v1/venues/#{venue.id}/favorite"
      expect(response).to have_http_status(:unauthorized)
    end

    it "adds a favorite" do
      expect {
        post "/api/v1/venues/#{venue.id}/favorite", headers: auth_headers(user)
      }.to change { user.favorites.count }.by(1)
      expect(response).to have_http_status(:created)
    end

    it "is idempotent" do
      post "/api/v1/venues/#{venue.id}/favorite", headers: auth_headers(user)
      expect {
        post "/api/v1/venues/#{venue.id}/favorite", headers: auth_headers(user)
      }.not_to change { user.favorites.count }
    end
  end

  describe "DELETE /api/v1/venues/:venue_id/favorite" do
    it "removes a favorite" do
      create(:favorite_venue, user: user, venue: venue)
      expect {
        delete "/api/v1/venues/#{venue.id}/favorite", headers: auth_headers(user)
      }.to change { user.favorites.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "GET /api/v1/favorites" do
    it "lists the user's favorite venues" do
      create(:favorite_venue, user: user, venue: create(:venue, name: "Faved"))
      get "/api/v1/favorites", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(json["data"].map { |v| v["name"] }).to eq([ "Faved" ])
    end

    it "requires auth" do
      get "/api/v1/favorites"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
