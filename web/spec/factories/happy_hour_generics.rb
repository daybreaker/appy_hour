# == Schema Information
#
# Table name: happy_hour_generics
#
#  id             :bigint           not null, primary key
#  applies_to     :string
#  description    :text
#  discount_type  :integer
#  discount_value :decimal(, )
#  status         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  happy_hour_id  :bigint           not null
#
# Indexes
#
#  index_happy_hour_generics_on_happy_hour_id  (happy_hour_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_hour_id => happy_hours.id)
#
FactoryBot.define do
  factory :happy_hour_generic do
    association :happy_hour
    applies_to { "drinks" }
    discount_type { :percentage }
    discount_value { "25.0" }
    description { "25% off all drafts" }
    status { :approved }
  end
end
