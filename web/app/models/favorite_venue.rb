class FavoriteVenue < ApplicationRecord
  belongs_to :user
  belongs_to :venue

  validates :venue_id, uniqueness: { scope: :user_id }
end
