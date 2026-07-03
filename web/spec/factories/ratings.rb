FactoryBot.define do
  factory :rating do
    association :user
    value { 4 }
    association :rateable, factory: :venue
  end
end
