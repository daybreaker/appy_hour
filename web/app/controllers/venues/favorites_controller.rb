module Venues
  class FavoritesController < ApplicationController
    before_action :set_venue

    def create
      current_user.favorite_venues.find_or_create_by!(venue: @venue)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to venue_path(@venue), notice: "Added to favorites." }
      end
    end

    def destroy
      current_user.favorite_venues.where(venue: @venue).destroy_all
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to venue_path(@venue), notice: "Removed from favorites." }
      end
    end

    private

    def set_venue
      @venue = Venue.kept.find(params[:venue_id])
    end
  end
end
