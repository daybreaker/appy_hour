# == Schema Information
#
# Table name: menu_items
#
#  id               :bigint           not null, primary key
#  base_price_cents :integer
#  currency         :string           default("USD"), not null
#  description      :text
#  item_type        :integer          default(0), not null
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  venue_id         :bigint           not null
#
# Indexes
#
#  index_menu_items_on_venue_id                (venue_id)
#  index_menu_items_on_venue_id_and_item_type  (venue_id,item_type)
#  index_menu_items_on_venue_id_and_name       (venue_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (venue_id => venues.id)
#
class MenuItem < ApplicationRecord
  belongs_to :venue
  has_many :menu_item_deals, dependent: :destroy

  enum :item_type, {
    food: 0, beer: 1, cocktail: 2, wine: 3, spirit: 4, na_bev: 5, other: 6
  }

  validates :name, presence: true
  validates :base_price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :currency, presence: true
end

