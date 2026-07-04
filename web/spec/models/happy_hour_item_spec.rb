require "rails_helper"

RSpec.describe HappyHourItem, type: :model do
  it { is_expected.to belong_to(:happy_hour) }
  it { is_expected.to validate_presence_of(:name) }

  describe "admin_entry context" do
    it "requires a description on admin entry" do
      item = build(:happy_hour_item, description: "")
      expect(item.valid?(:admin_entry)).to be false
      expect(item.errors[:description]).to be_present
    end

    it "does not require a description in the default (scraper) context" do
      item = build(:happy_hour_item, description: "")
      expect(item.valid?).to be true
    end
  end
end
