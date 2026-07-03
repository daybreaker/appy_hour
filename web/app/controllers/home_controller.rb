class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @day_of_week = parse_day(params[:day])
    @neighborhoods = Neighborhood.ordered

    venues = Venue.with_happy_hours_on(@day_of_week).includes(:neighborhood)
    venues = venues.in_neighborhood(params[:neighborhood_id]) if params[:neighborhood_id].present?

    @venues = venues
  end

  private

  # Defaults to today; accepts an explicit 0-6 day param for browsing other days.
  def parse_day(value)
    day = value.to_i
    (0..6).cover?(day) && value.present? ? day : Date.current.wday
  end
end
