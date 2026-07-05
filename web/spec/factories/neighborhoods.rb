# == Schema Information
#
# Table name: neighborhoods
#
#  id         :bigint           not null, primary key
#  city       :string           not null
#  name       :string           not null
#  slug       :string           not null
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_neighborhoods_on_slug                     (slug) UNIQUE
#  index_neighborhoods_on_state_and_city_and_name  (state,city,name) UNIQUE
#
FactoryBot.define do
  factory :neighborhood do
    sequence(:name) { |n| "Neighborhood #{n}" }
    city { "Cleveland" }
    sequence(:slug) { |n| "cleveland-neighborhood-#{n}" }
  end
end
