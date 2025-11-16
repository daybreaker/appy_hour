# app/controllers/api/v1/venues_controller.rb
module Api
  module V1
    class VenuesController < ApplicationController
      before_action :set_venue,          only: %i[show update destroy]
      before_action :authenticate_user!, only: %i[create update destroy]
      before_action :require_admin!,     only: %i[create update destroy]

      # GET /api/v1/venues
      def index
        scope = Venue.all
        scope = apply_filter(scope)
        total = scope.count

        scope = apply_sort(scope)
        scope = apply_pagination(scope)

        render json: scope.map { |v| serialize_venue(v) }
      end

      # GET /api/v1/venues/:id
      def show
        render json: { data: serialize_venue(@venue) }
      end

      # POST /api/v1/venues
      def create
        @venue = Venue.new(venue_params.except(:lat, :lng))
        set_point_from_params(@venue, venue_params[:lng], venue_params[:lat])

        if @venue.save
          render json: { data: serialize_venue(@venue) }, status: :created
        else
          render json: { errors: @venue.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT/PATCH /api/v1/venues/:id
      def update
        @venue.assign_attributes(venue_params.except(:lat, :lng))
        set_point_from_params(@venue, venue_params[:lng], venue_params[:lat]) if venue_params.key?(:lng) || venue_params.key?(:lat)

        if @venue.save
          render json: { data: serialize_venue(@venue) }
        else
          render json: { errors: @venue.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/venues/:id
      def destroy
        @venue.destroy
        head :no_content
      end

      private

      def set_venue
        @venue = Venue.find(params[:id])
      end

      # react-admin sends:
      # _page, _perPage, _sort, _order, filter (JSON), and sometimes ids[]
      def apply_pagination(scope)
        page     = params.fetch(:_page, 1).to_i
        per_page = params.fetch(:_perPage, 25).to_i
        page = 1 if page < 1
        per_page = 1000 if per_page > 1000 # hard cap
        offset = (page - 1) * per_page
        scope.offset(offset).limit(per_page)

        total = scope.count

        # Content-Range for react-admin (handle empty page safely)
        start_idx = total.zero? ? 0 : offset
        end_idx   = total.zero? ? 0 : (offset + records.size - 1).clamp(offset, [total - 1, offset].max)
        response.set_header 'Content-Range', "venues #{start_idx}-#{end_idx}/#{total}"

        scope
      end

      def apply_sort(scope)
        sort  = params[:_sort].presence || 'name'
        order = params[:_order].to_s.upcase == 'DESC' ? :desc : :asc
        # whitelist to avoid SQL injection
        allowed = %w[name created_at updated_at tz_name]
        sort = 'name' unless allowed.include?(sort)
        scope.order(sort => order)
      end

      def apply_filter(scope)
        # ids filter (used by ReferenceArrayInput)
        if params[:ids].present?
          return scope.where(id: params[:ids])
        end

        raw = params[:filter].presence
        filter = raw.present? ? JSON.parse(raw) : {}

        if (q = filter['q']).present?
          scope = scope.where('name ILIKE ?', "%#{q}%")
        end

        # geo: lng, lat, meters (geography, meters)
        if filter['lng'].present? && filter['lat'].present? && filter['meters'].present?
          lng = filter['lng'].to_f
          lat = filter['lat'].to_f
          meters = filter['meters'].to_i
          factory = RGeo::Geographic.spherical_factory(srid: 4326)
          pt = factory.point(lng, lat)
          scope = scope.where('ST_DWithin(location, ST_GeogFromText(?), ?)', pt.as_text, meters)
        end

        scope
      end

      # Strong params; allow lat/lng as virtuals for PostGIS point
      def venue_params
        params.require(:venue).permit(
          :name, :description, :website_url, :tz_name,
          :lat, :lng,
          social_handles: {}
        )
      end

      # Convert lat/lng → PostGIS geography(Point,4326)
      def set_point_from_params(venue, lng_param, lat_param)
        return if lng_param.blank? || lat_param.blank?
        factory = RGeo::Geographic.spherical_factory(srid: 4326)
        venue.location = factory.point(lng_param.to_f, lat_param.to_f)
      end

      # Serialize model → JSON expected by admin
      def serialize_venue(v)
        lat = v.location&.respond_to?(:latitude) ? v.location.latitude : nil
        lng = v.location&.respond_to?(:longitude) ? v.location.longitude : nil
        {
          id: v.id,
          name: v.name,
          description: v.description,
          website_url: v.website_url,
          tz_name: v.tz_name,
          social_handles: v.social_handles || {},
          lat: lat,
          lng: lng,
          created_at: v.created_at,
          updated_at: v.updated_at
        }
      end
    end
  end
end
