module Admin
  class VenuesController < BaseController
    include Pagy::Method

    def index
      @pagy, @venues = pagy(
        Venue.needs_investigation.kept
          .includes(:neighborhood, :scraper_runs, :social_links)
          .order(updated_at: :asc),
        limit: 25
      )
    end

    def update
      @venue = Venue.find(params[:id])

      if params[:clear_investigation]
        @venue.update!(needs_investigation: false)
        flash[:notice] = "Marked as reviewed."
      end

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@venue) }
        format.html { redirect_to admin_venues_path }
      end
    end
  end
end
