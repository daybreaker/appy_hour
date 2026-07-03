module Admin
  class HappyHoursController < BaseController
    include Pagy::Method

    def index
      @pagy, @happy_hours = pagy(
        HappyHour.needs_review
          .includes(:venue, :submitted_by, happy_hour_days: [ :happy_hour_generics, :happy_hour_items, :happy_hour_bogos ])
          .order(created_at: :asc),
        limit: 25
      )
    end

    def update
      @happy_hour = HappyHour.find(params[:id])
      service = HappyHours::ApprovalService.new(@happy_hour, current_user)

      if params[:approve]
        service.approve!
        flash[:notice] = "Happy hour approved."
      elsif params[:reject]
        service.reject!(reason: happy_hour_params[:notes])
        flash[:notice] = "Happy hour rejected."
      end

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@happy_hour) }
        format.html { redirect_to admin_happy_hours_path }
      end
    end

    private

    def happy_hour_params
      params.fetch(:happy_hour, {}).permit(:notes)
    end
  end
end
