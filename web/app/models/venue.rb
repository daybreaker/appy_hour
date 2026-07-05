# == Schema Information
#
# Table name: venues
#
#  id                  :bigint           not null, primary key
#  address             :string
#  city                :string
#  discarded_at        :datetime
#  lonlat              :geography        point, 4326
#  name                :string           not null
#  needs_investigation :boolean          default(FALSE), not null
#  phone               :string
#  scraper_status      :integer          default("not_scraped"), not null
#  state               :string
#  website_url         :string
#  zip_code            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  google_place_id     :string
#  neighborhood_id     :bigint
#
# Indexes
#
#  index_venues_on_city                 (city)
#  index_venues_on_discarded_at         (discarded_at)
#  index_venues_on_google_place_id      (google_place_id) UNIQUE
#  index_venues_on_lonlat               (lonlat) USING gist
#  index_venues_on_needs_investigation  (needs_investigation)
#  index_venues_on_neighborhood_id      (neighborhood_id)
#  index_venues_on_zip_code             (zip_code)
#
# Foreign Keys
#
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#
class Venue < ApplicationRecord
  include Discard::Model

  belongs_to :neighborhood, optional: true

  has_many :happy_hours, dependent: :destroy
  has_many :social_links, dependent: :destroy
  has_many :favorite_venues, dependent: :destroy
  has_many :favorited_by, through: :favorite_venues, source: :user
  has_many :ratings, as: :rateable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :scraper_runs, dependent: :destroy

  accepts_nested_attributes_for :social_links, allow_destroy: true,
    reject_if: ->(attrs) { attrs[:handle].blank? }

  enum :scraper_status, {
    not_scraped: 0,
    scraped_found: 1,
    scraped_not_found: 2,
    scrape_failed: 3
  }, validate: true

  validates :name, presence: true

  scope :needs_investigation, -> { where(needs_investigation: true) }
  scope :with_happy_hours, -> { joins(:happy_hours).where(happy_hours: { status: :approved }).distinct }
  scope :with_happy_hours_on, ->(day_of_week) {
    kept.joins(happy_hours: :happy_hour_days)
      .where(happy_hours: { status: :approved })
      .where(happy_hour_days: { day_of_week: day_of_week })
      .distinct
  }
  scope :in_neighborhood, ->(neighborhood_id) { where(neighborhood_id: neighborhood_id) }
  # Orders a (non-DISTINCT) relation so the user's favorites come first, then
  # by name. Used on the paginated venues index.
  scope :favorites_first_for, ->(user) {
    next order(:name) if user.nil?

    join = sanitize_sql_array([
      "LEFT JOIN favorite_venues ON favorite_venues.venue_id = venues.id AND favorite_venues.user_id = ?",
      user.id
    ])
    joins(join).order(Arel.sql("favorite_venues.id IS NULL"), :name)
  }
  scope :near, ->(lat, lng, radius_meters) {
    where("ST_DWithin(lonlat, ST_MakePoint(?, ?)::geography, ?)", lng, lat, radius_meters)
      .order(Arel.sql("ST_Distance(lonlat, ST_MakePoint(#{lng.to_f}, #{lat.to_f})::geography)"))
  }

  def coordinates=(lat_lng)
    self.lonlat = "POINT(#{lat_lng[:lng]} #{lat_lng[:lat]})" if lat_lng
  end

  def latitude
    lonlat&.latitude
  end

  def longitude
    lonlat&.longitude
  end
end
