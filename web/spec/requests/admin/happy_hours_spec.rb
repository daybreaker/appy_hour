require "rails_helper"

RSpec.describe "Admin::HappyHours", type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:venue) { create(:venue) }

  before { sign_in admin }

  describe "GET /admin/happy_hours" do
    it "lists happy hours needing review" do
      pending_hh = create(:happy_hour, status: :pending, venue: venue)
      approved_hh = create(:happy_hour, :approved, venue: venue)

      get admin_happy_hours_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(venue.name)
      expect(response.body).to include("happy_hour_#{pending_hh.id}\"")
      expect(response.body).not_to include("happy_hour_#{approved_hh.id}\"")
    end
  end

  describe "GET /admin/happy_hours/:id (editor)" do
    it "renders the editor with the deal picker and schedule" do
      happy_hour = create(:happy_hour, status: :pending, venue: venue)
      create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 3)
      create(:happy_hour_generic, happy_hour: happy_hour, applies_to: "drafts")
      get admin_happy_hour_path(happy_hour)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("happy_hour_#{happy_hour.id}_deals")
      expect(response.body).to include("deal-picker")
      expect(response.body).to include("drafts")
    end
  end

  describe "GET /admin/happy_hours/new and :id/edit" do
    it "renders the new form with the venue search widget" do
      get new_admin_happy_hour_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("venue-search")
    end

    it "prefills the venue when venue_id is passed" do
      venue = create(:venue, name: "Prefilled Bar")
      get new_admin_happy_hour_path(venue_id: venue.id)
      expect(response.body).to include("Prefilled Bar")
    end

    it "renders the edit form" do
      happy_hour = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 3)
      get edit_admin_happy_hour_path(happy_hour)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/happy_hours" do
    let(:valid_params) do
      { happy_hour: { venue_id: venue.id, notes: "House specials" } }
    end

    it "creates the shell (no days required up front), auto-approved, and redirects to the editor" do
      expect {
        post admin_happy_hours_path, params: valid_params
      }.to change(HappyHour, :count).by(1)

      hh = HappyHour.last
      expect(hh.status).to eq("approved")
      expect(hh.venue).to eq(venue)
      expect(hh.happy_hour_days).to be_empty
      expect(response).to redirect_to(admin_happy_hour_path(hh))
    end

    it "re-renders when no venue is selected" do
      post admin_happy_hours_path, params: { happy_hour: { venue_id: "", notes: "x" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(HappyHour.count).to eq(0)
    end

    it "accepts an all-day day with no times" do
      post admin_happy_hours_path, params: { happy_hour: {
        venue_id: venue.id,
        happy_hour_days_attributes: { "0" => { day_of_week: "3", all_day: "1", start_time: "", end_time: "" } }
      } }
      day = HappyHour.last.happy_hour_days.first
      expect(day.all_day).to be true
      expect(day.start_time).to be_nil
    end
  end

  describe "PATCH /admin/happy_hours/:id (edit attributes)" do
    let!(:happy_hour) { create(:happy_hour, :approved, venue: venue) }

    it "updates notes and source_url" do
      patch admin_happy_hour_path(happy_hour), params: { happy_hour: { notes: "Updated", source_url: "https://x.com/hh" } }
      expect(happy_hour.reload.notes).to eq("Updated")
      expect(happy_hour.source_url).to eq("https://x.com/hh")
    end
  end

  describe "DELETE /admin/happy_hours/:id" do
    it "deletes the happy hour" do
      happy_hour = create(:happy_hour, venue: venue)
      expect {
        delete admin_happy_hour_path(happy_hour)
      }.to change(HappyHour, :count).by(-1)
    end
  end

  describe "PATCH /admin/happy_hours/:id/approve" do
    let!(:happy_hour) { create(:happy_hour, status: :pending, venue: venue) }

    it "approves and records the approver" do
      patch approve_admin_happy_hour_path(happy_hour)
      expect(happy_hour.reload.status).to eq("approved")
      expect(happy_hour.approved_by).to eq(admin)
      expect(happy_hour.approved_at).to be_present
    end

    it "turns a pending_deletion into deleted" do
      happy_hour.update!(status: :pending_deletion)
      patch approve_admin_happy_hour_path(happy_hour)
      expect(happy_hour.reload.status).to eq("deleted")
    end

    it "redirects to the queue on HTML" do
      patch approve_admin_happy_hour_path(happy_hour)
      expect(response).to redirect_to(admin_happy_hours_path)
    end
  end

  describe "PATCH /admin/happy_hours/:id/reject" do
    let!(:happy_hour) { create(:happy_hour, status: :pending, venue: venue) }

    it "rejects with a reason" do
      patch reject_admin_happy_hour_path(happy_hour), params: { happy_hour: { notes: "Inaccurate" } }
      expect(happy_hour.reload.status).to eq("rejected")
      expect(happy_hour.notes).to eq("Inaccurate")
    end
  end
end
