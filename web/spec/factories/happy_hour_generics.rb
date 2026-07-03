FactoryBot.define do
  factory :happy_hour_generic do
    association :happy_hour_day
    applies_to { "drinks" }
    discount_type { :percentage }
    discount_value { "25.0" }
    description { "25% off all drafts" }
    status { :approved }
  end
end
