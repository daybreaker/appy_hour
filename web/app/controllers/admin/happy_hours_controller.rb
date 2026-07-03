module Admin
  class HappyHoursController < BaseController
    include Pagy::Method

    before_action :set_happy_hour, only: [ :show, :edit, :update, :destroy, :approve, :reject ]

    def index
      @pagy, @happy_hours = pagy(
        HappyHour.needs_review
          .includes(:venue, :submitted_by, happy_hour_days: [ :happy_hour_generics, :happy_hour_items, :happy_hour_bogos ])
          .order(created_at: :asc),
        limit: 25
      )
    end

    # The editor: days + dynamic deal management.
    def show
    end

    def new
      @happy_hour = HappyHour.new(venue_id: params[:venue_id])
      @happy_hour.happy_hour_days.build(day_of_week: Date.current.wday)
    end

    def create
      @happy_hour = HappyHours::SubmissionService.new(
        venue: Venue.find(happy_hour_params[:venue_id]),
        submitter: current_user,
        params: happy_hour_params.except(:venue_id)
      ).call

      if @happy_hour.persisted?
        redirect_to admin_happy_hour_path(@happy_hour), notice: "Happy hour created. Now add the deals."
      else
        @happy_hour.happy_hour_days.build if @happy_hour.happy_hour_days.empty?
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @happy_hour.update(happy_hour_params.except(:venue_id))
        redirect_to admin_happy_hour_path(@happy_hour), notice: "Happy hour updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @happy_hour.destroy
      redirect_to admin_happy_hours_path, notice: "Happy hour deleted."
    end

    def approve
      HappyHours::ApprovalService.new(@happy_hour, current_user).approve!
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@happy_hour) }
        format.html { redirect_to admin_happy_hours_path, notice: "Happy hour approved." }
      end
    end

    def reject
      HappyHours::ApprovalService.new(@happy_hour, current_user).reject!(reason: happy_hour_params[:notes])
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@happy_hour) }
        format.html { redirect_to admin_happy_hours_path, notice: "Happy hour rejected." }
      end
    end

    private

    def set_happy_hour
      @happy_hour = HappyHour.find(params[:id])
    end

    def happy_hour_params
      params.require(:happy_hour).permit(
        :venue_id, :notes, :source_url,
        happy_hour_days_attributes: [ :id, :day_of_week, :start_time, :end_time, :_destroy ]
      )
    end
  end
end
