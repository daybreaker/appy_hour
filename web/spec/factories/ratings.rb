# == Schema Information
#
# Table name: ratings
#
#  id            :bigint           not null, primary key
#  rateable_type :string           not null
#  value         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  rateable_id   :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_ratings_on_rateable  (rateable_type,rateable_id)
#  index_ratings_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :rating do
    association :user
    value { 4 }
    association :rateable, factory: :venue
  end
end
