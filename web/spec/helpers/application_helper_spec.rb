require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#deal_type_label" do
    it "labels a food item 'Food'" do
      item = build(:happy_hour_item, category: "food")
      expect(helper.deal_type_label(item)).to eq("Food")
    end

    it "labels a drink item 'Drink'" do
      item = build(:happy_hour_item, category: "drink")
      expect(helper.deal_type_label(item)).to eq("Drink")
    end

    it "falls back to 'Item' when the category is blank" do
      item = build(:happy_hour_item, category: nil)
      expect(helper.deal_type_label(item)).to eq("Item")
    end

    it "labels a BOGO deal 'BOGO'" do
      bogo = build(:happy_hour_bogo)
      expect(helper.deal_type_label(bogo)).to eq("BOGO")
    end

    it "labels a generic deal from its model name (shown uppercased via CSS)" do
      generic = build(:happy_hour_generic)
      expect(helper.deal_type_label(generic)).to eq("generic")
    end
  end
end
