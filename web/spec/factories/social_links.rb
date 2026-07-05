# == Schema Information
#
# Table name: social_links
#
#  id         :bigint           not null, primary key
#  platform   :integer          default("other"), not null
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  venue_id   :bigint           not null
#
# Indexes
#
#  index_social_links_on_venue_id          (venue_id)
#  index_social_links_on_venue_id_and_url  (venue_id,url) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (venue_id => venues.id)
#
FactoryBot.define do
  factory :social_link do
    association :venue
    platform { :instagram }
    sequence(:url) { |n| "https://instagram.com/venue#{n}" }
  end
end
