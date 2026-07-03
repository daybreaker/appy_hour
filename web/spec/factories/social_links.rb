FactoryBot.define do
  factory :social_link do
    association :venue
    platform { :instagram }
    sequence(:url) { |n| "https://instagram.com/venue#{n}" }
  end
end
