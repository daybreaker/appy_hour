FactoryBot.define do
  factory :happy_hour_bogo do
    happy_hour_day { nil }
    buy_quantity { 1 }
    get_quantity { 1 }
    get_discount_type { 1 }
    get_discount_value { "9.99" }
    applies_to { "MyString" }
    item_name { "MyString" }
    description { "MyText" }
    status { 1 }
  end
end
