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
class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :rateable, polymorphic: true

  validates :value, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: [ :rateable_type, :rateable_id ], message: "has already rated this" }
end
