require "rails_helper"

RSpec.describe HappyHourBogo, type: :model do
  it { is_expected.to belong_to(:happy_hour) }
  it { is_expected.to validate_presence_of(:applies_to) }

  describe "admin_entry context" do
    it "requires name and description on admin entry" do
      bogo = build(:happy_hour_bogo, item_name: "", description: "")
      expect(bogo.valid?(:admin_entry)).to be false
      expect(bogo.errors[:item_name]).to be_present
      expect(bogo.errors[:description]).to be_present
    end

    it "does not require them in the default (scraper) context" do
      bogo = build(:happy_hour_bogo, item_name: "", description: "")
      expect(bogo.valid?).to be true
    end
  end

  describe "discount value" do
    it "requires a value for non-free bogos" do
      expect(build(:happy_hour_bogo, get_discount_type: :percentage, get_discount_value: nil)).not_to be_valid
    end
  end
end
