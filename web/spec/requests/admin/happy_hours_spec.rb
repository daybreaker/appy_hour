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
      expect(response.body).not_to include(approved_hh.id.to_s)
    end
  end

  describe "PATCH /admin/happy_hours/:id" do
    let!(:happy_hour) { create(:happy_hour, status: :pending, venue: venue) }

    context "when approving" do
      it "sets status to approved" do
        patch admin_happy_hour_path(happy_hour), params: { approve: "1" }
        expect(happy_hour.reload.status).to eq("approved")
      end

      it "records the approver" do
        patch admin_happy_hour_path(happy_hour), params: { approve: "1" }
        expect(happy_hour.reload.approved_by).to eq(admin)
      end

      it "sets approved_at" do
        patch admin_happy_hour_path(happy_hour), params: { approve: "1" }
        expect(happy_hour.reload.approved_at).to be_present
      end

      it "redirects back to the queue on HTML request" do
        patch admin_happy_hour_path(happy_hour), params: { approve: "1" }
        expect(response).to redirect_to(admin_happy_hours_path)
      end
    end

    context "when rejecting" do
      it "sets status to rejected" do
        patch admin_happy_hour_path(happy_hour), params: { reject: "1", happy_hour: { notes: "Inaccurate info" } }
        expect(happy_hour.reload.status).to eq("rejected")
      end

      it "saves the rejection notes" do
        patch admin_happy_hour_path(happy_hour), params: { reject: "1", happy_hour: { notes: "Inaccurate info" } }
        expect(happy_hour.reload.notes).to eq("Inaccurate info")
      end
    end

    context "when approving a pending_deletion" do
      let!(:happy_hour) { create(:happy_hour, status: :pending_deletion, venue: venue) }

      it "sets status to deleted" do
        patch admin_happy_hour_path(happy_hour), params: { approve: "1" }
        expect(happy_hour.reload.status).to eq("deleted")
      end
    end
  end
end
