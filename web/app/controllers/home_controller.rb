class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @day_of_week = parse_day(params[:day])
    @neighborhoods = Neighborhood.ordered

    venues = Venue.with_happy_hours_on(@day_of_week).includes(:neighborhood)
    venues = venues.in_neighborhood(params[:neighborhood_id]) if params[:neighborhood_id].present?

    # Favorites float to the top, then alphabetical. (Unpaginated + DISTINCT
    # scope, so we order in Ruby rather than SQL.)
    favorites = current_user ? current_user.favorite_venues.pluck(:venue_id).to_set : Set.new
    @venues = venues.to_a.sort_by { |v| [ favorites.include?(v.id) ? 0 : 1, v.name.to_s.downcase ] }
  end

  private

  # Defaults to today; accepts an explicit 0-6 day param for browsing other days.
  def parse_day(value)
    day = value.to_i
    (0..6).cover?(day) && value.present? ? day : Date.current.wday
  end
end
