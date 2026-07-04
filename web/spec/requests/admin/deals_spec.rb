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
  end

  describe "item deals" do
    it "creates an item deal" do
      expect {
        post admin_happy_hour_item_deals_path(happy_hour),
          params: { happy_hour_item: { name: "Nachos", category: "food", happy_hour_price: 6 } },
          as: :turbo_stream
      }.to change { happy_hour.happy_hour_items.count }.by(1)
      expect(response.body).to include("Nachos")
    end
  end

  describe "bogo deals" do
    it "creates a bogo deal" do
      expect {
        post admin_happy_hour_bogo_deals_path(happy_hour),
          params: { happy_hour_bogo: { buy_quantity: 1, get_quantity: 1, get_discount_type: "free", applies_to: "wings" } },
          as: :turbo_stream
      }.to change { happy_hour.happy_hour_bogos.count }.by(1)
    end
  end

  describe "days" do
    it "adds a day via turbo stream" do
      expect {
        post admin_happy_hour_happy_hour_days_path(happy_hour),
          params: { happy_hour_day: { day_of_week: 3, all_day: "1" } }, as: :turbo_stream
      }.to change { happy_hour.happy_hour_days.count }.by(1)
    end

    it "removes a day" do
      day = create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 3)
      expect {
        delete admin_happy_hour_happy_hour_day_path(happy_hour, day), as: :turbo_stream
      }.to change { happy_hour.happy_hour_days.count }.by(-1)
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
