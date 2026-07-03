FactoryBot.define do
  factory :happy_hour_item do
    association :happy_hour_day
    name { "House Margarita" }
    category { "drink" }
    original_price { "12.00" }
    happy_hour_price { "7.00" }
    description { "" }
    status { :approved }
  end
end
