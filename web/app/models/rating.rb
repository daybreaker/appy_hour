class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :rateable, polymorphic: true

  validates :value, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: [ :rateable_type, :rateable_id ], message: "has already rated this" }
end
