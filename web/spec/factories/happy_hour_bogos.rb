# == Schema Information
#
# Table name: happy_hour_bogos
#
#  id                 :bigint           not null, primary key
#  applies_to         :string
#  buy_quantity       :integer
#  description        :text
#  get_discount_type  :integer
#  get_discount_value :decimal(, )
#  get_quantity       :integer
#  item_name          :string
#  status             :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  happy_hour_id      :bigint           not null
#
# Indexes
#
#  index_happy_hour_bogos_on_happy_hour_id  (happy_hour_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_hour_id => happy_hours.id)
#
FactoryBot.define do
  factory :happy_hour_bogo do
    association :happy_hour
    buy_quantity { 1 }
    get_quantity { 1 }
    get_discount_type { :free }
    get_discount_value { nil }
    applies_to { "wings" }
    item_name { "Boneless Wings" }
    description { "Buy one order, get one free" }
    status { :approved }
  end
end
