FactoryBot.define do
  factory :favorite_venue do
    association :user
    association :venue
  end
end
