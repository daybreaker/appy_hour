module Api
  module V1
    class NeighborhoodsController < BaseController
      skip_before_action :authenticate_api_user!, only: [ :index ]

      def index
        neighborhoods = Neighborhood.ordered
        render json: NeighborhoodSerializer.render_as_hash(neighborhoods), status: :ok
      end
    end
  end
end
