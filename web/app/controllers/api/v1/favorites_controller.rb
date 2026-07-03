module Api
  module V1
    class FavoritesController < BaseController
      def index
        venues = current_user.favorites.kept.includes(:neighborhood).order(:name)
        render json: { data: VenueSerializer.render_as_hash(venues) }, status: :ok
      end
    end
  end
end
