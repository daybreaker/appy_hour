require "rails_helper"

RSpec.describe HappyHourItem, type: :model do
  it { is_expected.to belong_to(:happy_hour) }
  it { is_expected.to validate_presence_of(:name) }

  it "does not require a description" do
    expect(build(:happy_hour_item, description: "")).to be_valid
    expect(build(:happy_hour_item, description: "").valid?(:admin_entry)).to be true
  end
end
