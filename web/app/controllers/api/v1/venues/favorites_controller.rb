module Api
  module V1
    module Venues
      class FavoritesController < BaseController
        before_action :set_venue

        def create
          current_user.favorite_venues.find_or_create_by!(venue: @venue)
          head :created
        end

        def destroy
          current_user.favorite_venues.where(venue: @venue).destroy_all
          head :no_content
        end

        private

        def set_venue
          @venue = Venue.kept.find(params[:venue_id])
        end
      end
    end
  end
end
