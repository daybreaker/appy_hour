module Admin
  class VenuesController < BaseController
    include Pagy::Method

    before_action :set_venue, only: [ :show, :edit, :update, :destroy, :clear_investigation ]

    def index
      scope = Venue.kept.includes(:neighborhood)
      scope = scope.needs_investigation if params[:filter] == "investigation"
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      @investigation = params[:filter] == "investigation"
      @pagy, @venues = pagy(scope.order(:name), limit: 25)
    end

    def show
      @happy_hours = @venue.happy_hours.includes(happy_hour_days: [ :happy_hour_generics, :happy_hour_items, :happy_hour_bogos ])
      @recent_runs = @venue.scraper_runs.order(run_at: :desc).limit(5)
    end

    def new
      @venue = Venue.new
    end

    def create
      @venue = Venue.new(venue_params)
      apply_coordinates(@venue)

      if @venue.save
        redirect_to admin_venue_path(@venue), notice: "Venue created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @venue.assign_attributes(venue_params)
      apply_coordinates(@venue)

      if @venue.save
        redirect_to admin_venue_path(@venue), notice: "Venue updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @venue.discard
      redirect_to admin_venues_path, notice: "Venue removed."
    end

    def clear_investigation
      @venue.update!(needs_investigation: false)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@venue) }
        format.html { redirect_to admin_venues_path(filter: "investigation"), notice: "Marked as reviewed." }
      end
    end

    private

    def set_venue
      @venue = Venue.find(params[:id])
    end

    def venue_params
      params.require(:venue).permit(
        :name, :address, :city, :zip_code, :phone, :website_url, :neighborhood_id
      )
    end

    # Sets the PostGIS point from optional lat/lng form fields.
    def apply_coordinates(venue)
      lat = params.dig(:venue, :latitude)
      lng = params.dig(:venue, :longitude)
      venue.coordinates = { lat: lat, lng: lng } if lat.present? && lng.present?
    end
  end
end
