require "rails_helper"

RSpec.describe "Admin deal management", type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:happy_hour) { create(:happy_hour, :approved) }

  before { sign_in admin }

  describe "generic deals" do
    it "creates an approved generic deal and streams it in" do
      expect {
        post admin_happy_hour_generic_deals_path(happy_hour),
          params: { happy_hour_generic: { applies_to: "drafts", discount_type: "percentage", discount_value: 25 } },
          as: :turbo_stream
      }.to change { happy_hour.happy_hour_generics.count }.by(1)

      deal = happy_hour.happy_hour_generics.last
      expect(deal.status).to eq("approved")
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("drafts")
    end

    it "re-renders the form with errors on invalid input" do
      post admin_happy_hour_generic_deals_path(happy_hour),
        params: { happy_hour_generic: { applies_to: "", discount_type: "percentage", discount_value: 25 } },
        as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content)
      expect(happy_hour.happy_hour_generics.count).to eq(0)
    end

    it "destroys a generic deal" do
      deal = create(:happy_hour_generic, happy_hour: happy_hour)
      expect {
        delete admin_happy_hour_generic_deal_path(happy_hour, deal), as: :turbo_stream
      }.to change { happy_hour.happy_hour_generics.count }.by(-1)
    end

    describe "inline edit" do
      let!(:deal) { create(:happy_hour_generic, happy_hour: happy_hour, applies_to: "drafts", discount_value: 10) }

      it "renders the edit form in the deal's frame" do
        get edit_admin_happy_hour_generic_deal_path(happy_hour, deal)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("turbo-frame")
        expect(response.body).to include(ActionView::RecordIdentifier.dom_id(deal))
      end

      it "updates the deal and renders it back" do
        patch admin_happy_hour_generic_deal_path(happy_hour, deal),
          params: { happy_hour_generic: { applies_to: "wine", discount_value: 20 } }
        expect(response).to have_http_status(:ok)
        expect(deal.reload.applies_to).to eq("wine")
        expect(deal.discount_value).to eq(20)
      end

      it "re-renders the form on invalid input" do
        patch admin_happy_hour_generic_deal_path(happy_hour, deal),
          params: { happy_hour_generic: { applies_to: "" } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(deal.reload.applies_to).to eq("drafts")
      end

      it "shows the read-only row (cancel)" do
        get admin_happy_hour_generic_deal_path(happy_hour, deal)
        expect(response.body).to include("Edit")
        expect(response.body).to include("drafts")
      end
    end
  end

  describe "item deals" do
    it "creates an item deal (description optional, no regular price needed)" do
      expect {
        post admin_happy_hour_item_deals_path(happy_hour),
          params: { happy_hour_item: { name: "Nachos", category: "food", happy_hour_price: 6 } },
          as: :turbo_stream
      }.to change { happy_hour.happy_hour_items.count }.by(1)
      expect(response.body).to include("Nachos")
    end
  end

  describe "bogo deals" do
    it "creates a bogo deal with a name" do
      expect {
        post admin_happy_hour_bogo_deals_path(happy_hour),
          params: { happy_hour_bogo: { buy_quantity: 1, get_quantity: 1, get_discount_type: "free",
                                       applies_to: "wings", item_name: "Boneless Wings" } },
          as: :turbo_stream
      }.to change { happy_hour.happy_hour_bogos.count }.by(1)
    end

    it "requires a name" do
      post admin_happy_hour_bogo_deals_path(happy_hour),
        params: { happy_hour_bogo: { buy_quantity: 1, get_quantity: 1, get_discount_type: "free", applies_to: "wings" } },
        as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content)
      expect(happy_hour.happy_hour_bogos.count).to eq(0)
    end
  end

  describe "days" do
    it "adds a day via turbo stream" do
      expect {
        post admin_happy_hour_happy_hour_days_path(happy_hour),
          params: { happy_hour_day: { day_of_week: 3, all_day: "1" } }, as: :turbo_stream
      }.to change { happy_hour.happy_hour_days.count }.by(1)
    end

    it "bulk-adds one day per selected weekday sharing the same time" do
      expect {
        post bulk_admin_happy_hour_happy_hour_days_path(happy_hour),
          params: { days_of_week: [ "1", "2", "3", "4", "5" ],
                    happy_hour_day: { start_time: "16:00", end_time: "18:00" } },
          as: :turbo_stream
      }.to change { happy_hour.happy_hour_days.count }.by(5)

      expect(happy_hour.happy_hour_days.pluck(:day_of_week)).to match_array([ 1, 2, 3, 4, 5 ])
      expect(happy_hour.happy_hour_days.map(&:hours_label).uniq).to eq([ "4:00 PM – 6:00 PM" ])
    end

    it "bulk-adds all-day entries with a note" do
      post bulk_admin_happy_hour_happy_hour_days_path(happy_hour),
        params: { days_of_week: [ "0", "6" ],
                  happy_hour_day: { all_day: "1", note: "Weekend special" } }, as: :turbo_stream
      days = happy_hour.happy_hour_days
      expect(days.count).to eq(2)
      expect(days.all?(&:all_day?)).to be true
      expect(days.map(&:note).uniq).to eq([ "Weekend special" ])
    end

    it "bulk create rejects no days selected" do
      post bulk_admin_happy_hour_happy_hour_days_path(happy_hour),
        params: { days_of_week: [], happy_hour_day: { all_day: "1" } }, as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content)
      expect(happy_hour.happy_hour_days.count).to eq(0)
    end

    it "bulk create rejects invalid times without creating anything" do
      post bulk_admin_happy_hour_happy_hour_days_path(happy_hour),
        params: { days_of_week: [ "1", "2" ], happy_hour_day: { start_time: "18:00", end_time: "16:00" } },
        as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content)
      expect(happy_hour.happy_hour_days.count).to eq(0)
    end

    it "supports two entries for the same weekday with a note" do
      post admin_happy_hour_happy_hour_days_path(happy_hour),
        params: { happy_hour_day: { day_of_week: 1, start_time: "15:00", end_time: "18:00" } }, as: :turbo_stream
      post admin_happy_hour_happy_hour_days_path(happy_hour),
        params: { happy_hour_day: { day_of_week: 1, all_day: "1", note: "For service industry workers" } },
        as: :turbo_stream

      mondays = happy_hour.happy_hour_days.where(day_of_week: 1)
      expect(mondays.count).to eq(2)
      expect(mondays.find_by(all_day: true).note).to eq("For service industry workers")
      expect(response.body).to include("For service industry workers")
    end

    it "removes a day" do
      day = create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 3)
      expect {
        delete admin_happy_hour_happy_hour_day_path(happy_hour, day), as: :turbo_stream
      }.to change { happy_hour.happy_hour_days.count }.by(-1)
    end

    describe "inline edit" do
      let!(:day) { create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 1, start_time: "16:00", end_time: "18:00") }

      it "renders the edit form in the day's frame" do
        get edit_admin_happy_hour_happy_hour_day_path(happy_hour, day)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(ActionView::RecordIdentifier.dom_id(day))
      end

      it "updates the day (e.g. switch to all-day with a note)" do
        patch admin_happy_hour_happy_hour_day_path(happy_hour, day),
          params: { happy_hour_day: { all_day: "1", note: "Industry night" } }
        expect(response).to have_http_status(:ok)
        day.reload
        expect(day.all_day).to be true
        expect(day.start_time).to be_nil
        expect(day.note).to eq("Industry night")
      end

      it "re-renders the form on invalid input" do
        patch admin_happy_hour_happy_hour_day_path(happy_hour, day),
          params: { happy_hour_day: { all_day: "0", start_time: "18:00", end_time: "16:00" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "authorization" do
    it "blocks non-admins" do
      sign_out admin
      sign_in create(:user, role: :editor)
      post admin_happy_hour_generic_deals_path(happy_hour),
        params: { happy_hour_generic: { applies_to: "x", discount_type: "percentage", discount_value: 1 } }
      expect(response).to redirect_to(root_path)
    end
  end
end
