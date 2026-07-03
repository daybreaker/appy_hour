require "rails_helper"

RSpec.describe "Api::V1::Venues::HappyHours", type: :request do
  let(:venue) { create(:venue) }
  let(:valid_params) do
    {
      happy_hour: {
        notes: "$5 drafts",
        happy_hour_days_attributes: [
          { day_of_week: 3, start_time: "16:00", end_time: "18:00" }
        ]
      }
    }
  end

  describe "POST /api/v1/venues/:venue_id/happy_hours" do
    it "returns 401 without a token" do
      post "/api/v1/venues/#{venue.id}/happy_hours", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    context "as a regular user" do
      let(:user) { create(:user, role: :user) }

      it "creates a pending happy hour" do
        expect {
          post "/api/v1/venues/#{venue.id}/happy_hours", params: valid_params, headers: auth_headers(user)
        }.to change(HappyHour, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(HappyHour.last.status).to eq("pending")
        expect(HappyHour.last.submitted_by).to eq(user)
      end
    end

    context "as an editor" do
      let(:editor) { create(:user, role: :editor) }

      it "auto-approves the submission" do
        post "/api/v1/venues/#{venue.id}/happy_hours", params: valid_params, headers: auth_headers(editor)
        expect(HappyHour.last.status).to eq("approved")
      end
    end

    it "returns 422 with errors on invalid input" do
      user = create(:user)
      post "/api/v1/venues/#{venue.id}/happy_hours",
        params: { happy_hour: { notes: "", happy_hour_days_attributes: [] } },
        headers: auth_headers(user)

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["errors"]).to be_present
    end
  end
end
