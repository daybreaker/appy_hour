require "rails_helper"

RSpec.describe "Venues::Favorites", type: :request do
  let(:user) { create(:user) }
  let(:venue) { create(:venue) }

  describe "POST /venues/:venue_id/favorite" do
    it "requires login" do
      post venue_favorite_path(venue)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "adds the venue to the user's favorites" do
      sign_in user
      expect {
        post venue_favorite_path(venue)
      }.to change { user.favorites.count }.by(1)
    end

    it "is idempotent" do
      sign_in user
      post venue_favorite_path(venue)
      expect {
        post venue_favorite_path(venue)
      }.not_to change { user.favorites.count }
    end
  end

  describe "DELETE /venues/:venue_id/favorite" do
    it "removes the venue from favorites" do
      sign_in user
      create(:favorite_venue, user: user, venue: venue)
      expect {
        delete venue_favorite_path(venue)
      }.to change { user.favorites.count }.by(-1)
    end
  end
end
