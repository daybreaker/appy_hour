module Admin
  class HappyHourDaysController < BaseController
    before_action :set_happy_hour, only: [ :create ]

    def create
      @day = @happy_hour.happy_hour_days.new(day_params)

      if @day.save
        render turbo_stream: [
          turbo_stream.append("happy_hour_#{@happy_hour.id}_days",
            partial: "admin/happy_hours/day", locals: { day: @day }),
          turbo_stream.replace("happy_hour_#{@happy_hour.id}_day_form",
            partial: "admin/happy_hours/day_form", locals: { happy_hour: @happy_hour, day: @happy_hour.happy_hour_days.new })
        ]
      else
        render turbo_stream: turbo_stream.replace("happy_hour_#{@happy_hour.id}_day_form",
          partial: "admin/happy_hours/day_form", locals: { happy_hour: @happy_hour, day: @day }),
          status: :unprocessable_entity
      end
    end

    def destroy
      day = HappyHourDay.find(params[:id])
      dom_id = ActionView::RecordIdentifier.dom_id(day)
      day.destroy
      render turbo_stream: turbo_stream.remove(dom_id)
    end

    private

    def set_happy_hour
      @happy_hour = HappyHour.find(params[:happy_hour_id])
    end

    def day_params
      params.require(:happy_hour_day).permit(:day_of_week, :all_day, :start_time, :end_time)
    end
  end
end
