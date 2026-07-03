FactoryBot.define do
  factory :happy_hour_item do
    happy_hour_day { nil }
    name { "MyString" }
    category { "MyString" }
    original_price { "9.99" }
    happy_hour_price { "9.99" }
    description { "MyText" }
    status { 1 }
  end
end
