FactoryBot.define do
  factory :neighborhood do
    sequence(:name) { |n| "Neighborhood #{n}" }
    city { "Cleveland" }
    sequence(:slug) { |n| "cleveland-neighborhood-#{n}" }
  end
end
