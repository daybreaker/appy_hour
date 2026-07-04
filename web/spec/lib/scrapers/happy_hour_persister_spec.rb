require "rails_helper"

RSpec.describe Scrapers::HappyHourPersister do
  let(:venue) { create(:venue) }
  subject(:persister) { described_class.new(venue) }

  let(:extracted) do
    {
      "has_happy_hour" => true,
      "notes" => "Half off apps",
      "source_url" => "https://venue.com/hh",
      "days" => [
        { "day_of_week" => 1, "all_day" => true },
        { "day_of_week" => 3, "start_time" => "16:00", "end_time" => "18:00" }
      ],
      "generic_deals" => [ { "applies_to" => "drafts", "discount_type" => "percentage", "discount_value" => 25 } ],
      "item_deals" => [ { "name" => "Nachos", "category" => "food", "original_price" => 12, "happy_hour_price" => 7 } ],
      "bogo_deals" => [ { "buy_quantity" => 1, "get_quantity" => 1, "get_discount_type" => "free", "applies_to" => "wings" } ]
    }
  end

  describe "#persist" do
    it "creates a pending happy hour with schedule days and menu-level deals" do
      happy_hour = persister.persist(extracted)

      expect(happy_hour).to be_persisted
      expect(happy_hour.status).to eq("pending")
      expect(happy_hour.notes).to eq("Half off apps")
      expect(happy_hour.source_url).to eq("https://venue.com/hh")

      expect(happy_hour.happy_hour_days.count).to eq(2)
      expect(happy_hour.happy_hour_days.find_by(day_of_week: 1).all_day).to be true

      expect(happy_hour.happy_hour_generics.first).to have_attributes(applies_to: "drafts", status: "pending")
      expect(happy_hour.happy_hour_items.first).to have_attributes(name: "Nachos", status: "pending")
      expect(happy_hour.happy_hour_bogos.first).to have_attributes(applies_to: "wings", status: "pending")
    end

    it "returns nil and creates nothing when there are no valid days" do
      expect {
        result = persister.persist({ "days" => [ { "day_of_week" => 9 } ] })
        expect(result).to be_nil
      }.not_to change(HappyHour, :count)
    end

    it "skips malformed deals but still persists the menu" do
      data = {
        "days" => [ { "day_of_week" => 1, "start_time" => "15:00", "end_time" => "17:00" } ],
        "generic_deals" => [ { "applies_to" => "", "discount_type" => "percentage", "discount_value" => 10 } ],
        "item_deals" => [ { "name" => "Beer", "happy_hour_price" => 4 } ]
      }

      happy_hour = persister.persist(data)
      expect(happy_hour.happy_hour_generics).to be_empty
      expect(happy_hour.happy_hour_items.first.name).to eq("Beer")
    end
  end
end
