# == Schema Information
#
# Table name: venues
#
#  id             :bigint           not null, primary key
#  address        :string
#  address_2      :string
#  city           :string
#  description    :text
#  location       :geography        point, 4326
#  name           :string
#  social_handles :jsonb
#  state          :string
#  tz_name        :string
#  website_url    :string
#  zip_code       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_venues_on_location  (location) USING gist
#  index_venues_on_tz_name   (tz_name)
#
class Venue < ApplicationRecord
  has_many :menus, dependent: :destroy
  has_many :hours, as: :schedulable, dependent: :destroy
  has_many :menu_items, dependent: :destroy
  has_many :menu_item_deals, through: :menus

  validates :name, :tz_name, presence: true

  # PostGIS: proximity (meters)
  scope :near_point, ->(lng, lat, meters) {
    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    ref = factory.point(lng, lat)
    where("ST_DWithin(location, ST_GeogFromText(?), ?)", ref.as_text, meters)
  }

  # convenience setters
  def set_location!(lng:, lat:)
    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    update!(location: factory.point(lng, lat))
  end
end
