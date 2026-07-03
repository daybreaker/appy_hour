module Api
  module V1
    class VenuesController < BaseController
      include Pagy::Method

      skip_before_action :authenticate_api_user!, only: [ :index, :show ]
      before_action :authenticate_api_user, only: [ :index, :show ]

      def index
        scope = Venue.kept.includes(:neighborhood)

        if params[:day].present?
          scope = scope.with_happy_hours_on(params[:day].to_i)
        end

        if params[:neighborhood_id].present?
          scope = scope.in_neighborhood(params[:neighborhood_id])
        end

        if params[:lat].present? && params[:lng].present?
          radius = (params[:radius].presence || 5000).to_i
          scope = scope.near(params[:lat].to_f, params[:lng].to_f, radius)
        else
          scope = scope.order(:name)
        end

        pagy, venues = pagy(scope, limit: (params[:per_page].presence || 25).to_i)

        render json: {
          data: VenueSerializer.render_as_hash(venues),
          meta: pagy_meta(pagy)
        }, status: :ok
      end

      def show
        venue = Venue.kept.find(params[:id])
        render json: VenueSerializer.render_as_hash(venue, view: :detail), status: :ok
      end

      private

      def pagy_meta(pagy)
        {
          page: pagy.page,
          total_pages: pagy.last,
          count: pagy.count
        }
      end
    end
  end
end
