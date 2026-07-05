# == Schema Information
#
# Table name: favorite_venues
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#  venue_id   :bigint           not null
#
# Indexes
#
#  index_favorite_venues_on_user_id   (user_id)
#  index_favorite_venues_on_venue_id  (venue_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (venue_id => venues.id)
#
class FavoriteVenue < ApplicationRecord
  belongs_to :user
  belongs_to :venue

  validates :venue_id, uniqueness: { scope: :user_id }
end
