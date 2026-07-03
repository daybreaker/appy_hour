require "rails_helper"

RSpec.describe "Api::V1::Registrations", type: :request do
  describe "POST /api/v1/registrations" do
    it "creates a user and returns a token" do
      expect {
        post "/api/v1/registrations", params: {
          email: "new@example.com", password: "password123", password_confirmation: "password123"
        }
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["email"]).to eq("new@example.com")
      expect(json["api_token"]).to be_present
    end

    it "always assigns the user role (no privilege escalation)" do
      post "/api/v1/registrations", params: {
        email: "sneaky@example.com", password: "password123", password_confirmation: "password123",
        role: "admin"
      }
      expect(User.find_by(email: "sneaky@example.com").role).to eq("user")
    end

    it "returns validation errors on bad input" do
      post "/api/v1/registrations", params: { email: "bad", password: "x" }
      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to be_present
    end
  end
end
