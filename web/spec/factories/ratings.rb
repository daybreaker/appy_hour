FactoryBot.define do
  factory :rating do
    user { nil }
    value { 1 }
    rateable { nil }
  end
end
