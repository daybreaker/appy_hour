class Venue < ApplicationRecord
  include Discard::Model

  belongs_to :neighborhood, optional: true

  has_many :happy_hours, dependent: :destroy
  has_many :favorite_venues, dependent: :destroy
  has_many :favorited_by, through: :favorite_venues, source: :user
  has_many :ratings, as: :rateable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :scraper_runs, dependent: :destroy

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
