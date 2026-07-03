require "rails_helper"

RSpec.describe "Api::V1 misc endpoints", type: :request do
  describe "GET /api/v1/me" do
    it "returns the current user" do
      user = create(:user, email: "me@example.com")
      get "/api/v1/me", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(json["email"]).to eq("me@example.com")
    end

    it "does not expose the api_token in the default view" do
      user = create(:user)
      get "/api/v1/me", headers: auth_headers(user)
      expect(json).not_to have_key("api_token")
    end

    it "returns 401 without a token" do
      get "/api/v1/me"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/neighborhoods" do
    it "is public and returns neighborhoods" do
      create(:neighborhood, name: "Tremont")
      get "/api/v1/neighborhoods"
      expect(response).to have_http_status(:ok)
      expect(json.map { |n| n["name"] }).to include("Tremont")
    end
  end
end
