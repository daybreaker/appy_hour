FactoryBot.define do
  factory :happy_hour_bogo do
    association :happy_hour_day
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
