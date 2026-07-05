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
FactoryBot.define do
  factory :happy_hour_item do
    association :happy_hour
    name { "House Margarita" }
    category { "drink" }
    original_price { "12.00" }
    happy_hour_price { "7.00" }
    description { "" }
    status { :approved }
  end
end
