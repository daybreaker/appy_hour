module Venues
  class HappyHoursController < ApplicationController
    before_action :set_venue

    def new
      @happy_hour = @venue.happy_hours.build
      @happy_hour.happy_hour_days.build(day_of_week: Date.current.wday)
      authorize! :create, @happy_hour
    end

    def create
      authorize! :create, HappyHour

      @happy_hour = HappyHours::SubmissionService.new(
        venue: @venue,
        submitter: current_user,
        params: happy_hour_params
      ).call

      if @happy_hour.persisted?
        redirect_to venue_path(@venue), notice: submission_notice
      else
        @happy_hour.happy_hour_days.build(day_of_week: Date.current.wday) if @happy_hour.happy_hour_days.empty?
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_venue
      @venue = Venue.kept.find(params[:venue_id])
    end

    def happy_hour_params
      params.require(:happy_hour).permit(
        :notes, :source_url,
        happy_hour_days_attributes: [ :id, :day_of_week, :start_time, :end_time, :_destroy ]
      )
    end

    def submission_notice
      if current_user.staff?
        "Happy hour added and published."
      else
        "Thanks! Your submission is pending review and will appear once approved."
      end
    end
  end
end
