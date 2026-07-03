require "rails_helper"

RSpec.describe "Venues::HappyHours", type: :request do
  let(:venue) { create(:venue) }

  let(:valid_params) do
    {
      happy_hour: {
        notes: "Half off apps and $5 drafts",
        happy_hour_days_attributes: {
          "0" => { day_of_week: "3", start_time: "16:00", end_time: "18:00" }
        }
      }
    }
  end

  describe "GET /venues/:venue_id/happy_hours/new" do
    it "requires login" do
      get new_venue_happy_hour_path(venue)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "renders the form for a logged-in user" do
      sign_in create(:user)
      get new_venue_happy_hour_path(venue)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /venues/:venue_id/happy_hours" do
    context "as a regular user" do
      let(:user) { create(:user, role: :user) }
      before { sign_in user }

      it "creates a pending happy hour" do
        expect {
          post venue_happy_hours_path(venue), params: valid_params
        }.to change(HappyHour, :count).by(1)

        happy_hour = HappyHour.last
        expect(happy_hour.status).to eq("pending")
        expect(happy_hour.submitted_by).to eq(user)
      end

      it "creates the nested happy hour day" do
        post venue_happy_hours_path(venue), params: valid_params
        expect(HappyHour.last.happy_hour_days.count).to eq(1)
      end

      it "redirects to the venue with a pending-review message" do
        post venue_happy_hours_path(venue), params: valid_params
        expect(response).to redirect_to(venue_path(venue))
        follow_redirect!
        expect(response.body).to include("pending review")
      end
    end

    context "as an editor" do
      let(:editor) { create(:user, role: :editor) }
      before { sign_in editor }

      it "auto-approves the submission" do
        post venue_happy_hours_path(venue), params: valid_params
        happy_hour = HappyHour.last
        expect(happy_hour.status).to eq("approved")
        expect(happy_hour.approved_by).to eq(editor)
        expect(happy_hour.approved_at).to be_present
      end
    end

    context "with invalid params" do
      before { sign_in create(:user) }

      it "does not create a happy hour and re-renders the form" do
        bad_params = { happy_hour: { notes: "", happy_hour_days_attributes: {} } }
        expect {
          post venue_happy_hours_path(venue), params: bad_params
        }.not_to change(HappyHour, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
