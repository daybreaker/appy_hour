require "rails_helper"

RSpec.describe "Favorites page", type: :request do
  let(:user) { create(:user) }

  describe "GET /favorites" do
    it "requires login" do
      get favorites_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "lists the user's favorited venues" do
      sign_in user
      faved = create(:venue, name: "Faved Bar")
      create(:venue, name: "Other Bar")
      create(:favorite_venue, user: user, venue: faved)

      get favorites_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Faved Bar")
      expect(response.body).not_to include("Other Bar")
    end

    it "shows an empty state with no favorites" do
      sign_in user
      get favorites_path
      expect(response.body).to include("No favorites yet")
    end
  end
end
