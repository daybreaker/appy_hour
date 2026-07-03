FactoryBot.define do
  factory :happy_hour_generic do
    happy_hour_day { nil }
    applies_to { "MyString" }
    discount_type { 1 }
    discount_value { "9.99" }
    description { "MyText" }
    status { 1 }
  end
end
