require "rails_helper"

# == Schema Information
#
# Table name: happy_hour_items
#
#  id               :bigint           not null, primary key
#  category         :string
#  description      :text
#  happy_hour_price :decimal(, )
#  name             :string
#  original_price   :decimal(, )
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  happy_hour_id    :bigint           not null
#
# Indexes
#
#  index_happy_hour_items_on_happy_hour_id  (happy_hour_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_hour_id => happy_hours.id)
#
RSpec.describe HappyHourItem, type: :model do
  it { is_expected.to belong_to(:happy_hour) }
  it { is_expected.to validate_presence_of(:name) }

  it "does not require a description" do
    expect(build(:happy_hour_item, description: "")).to be_valid
    expect(build(:happy_hour_item, description: "").valid?(:admin_entry)).to be true
  end
end
