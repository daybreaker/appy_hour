module Api
  module V1
    module Venues
      class HappyHoursController < BaseController
        before_action :set_venue

        def create
          authorize! :create, HappyHour

          happy_hour = HappyHours::SubmissionService.new(
            venue: @venue,
            submitter: current_user,
            params: happy_hour_params
          ).call

          if happy_hour.persisted?
            render json: HappyHourSerializer.render_as_hash(happy_hour), status: :created
          else
            render json: { errors: happy_hour.errors.full_messages }, status: :unprocessable_content
          end
        end

        private

        def set_venue
          @venue = Venue.kept.find(params[:venue_id])
        end

        def happy_hour_params
          params.require(:happy_hour).permit(
            :notes, :source_url,
            happy_hour_days_attributes: [ :day_of_week, :all_day, :start_time, :end_time ]
          )
        end
      end
    end
  end
end
