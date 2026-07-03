require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  describe "POST /api/v1/sessions" do
    let!(:user) { create(:user, email: "member@example.com", password: "password123") }

    it "returns the user with a token on valid credentials" do
      post "/api/v1/sessions", params: { email: "member@example.com", password: "password123" }

      expect(response).to have_http_status(:ok)
      expect(json["email"]).to eq("member@example.com")
      expect(json["api_token"]).to eq(user.api_token)
    end

    it "is case-insensitive on email" do
      post "/api/v1/sessions", params: { email: "MEMBER@example.com", password: "password123" }
      expect(response).to have_http_status(:ok)
    end

    it "returns 401 on wrong password" do
      post "/api/v1/sessions", params: { email: "member@example.com", password: "wrong" }
      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to be_present
    end

    it "returns 401 on unknown email" do
      post "/api/v1/sessions", params: { email: "nobody@example.com", password: "password123" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/sessions" do
    let(:user) { create(:user) }

    it "rotates the api token" do
      old_token = user.api_token
      delete "/api/v1/sessions", headers: auth_headers(user)
      expect(response).to have_http_status(:no_content)
      expect(user.reload.api_token).not_to eq(old_token)
    end

    it "returns 401 without a token" do
      delete "/api/v1/sessions"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
