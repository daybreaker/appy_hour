module Admin
  class HappyHourDaysController < BaseController
    before_action :set_happy_hour

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

    # Renders the read-only day row back into its frame (used to cancel an edit).
    def show
      render partial: "admin/happy_hours/day", locals: { day: find_day }
    end

    # Swaps the day row for an inline edit form (same frame).
    def edit
      render partial: "admin/happy_hours/day_edit_form", locals: { happy_hour: @happy_hour, day: find_day }
    end

    def update
      @day = find_day

      if @day.update(day_params)
        render partial: "admin/happy_hours/day", locals: { day: @day }
      else
        render partial: "admin/happy_hours/day_edit_form", locals: { happy_hour: @happy_hour, day: @day },
               status: :unprocessable_entity
      end
    end

    def destroy
      day = find_day
      dom_id = ActionView::RecordIdentifier.dom_id(day)
      day.destroy
      render turbo_stream: turbo_stream.remove(dom_id)
    end

    private

    def set_happy_hour
      @happy_hour = HappyHour.find(params[:happy_hour_id])
    end

    def find_day
      @happy_hour.happy_hour_days.find(params[:id])
    end

    def day_params
      params.require(:happy_hour_day).permit(:day_of_week, :all_day, :start_time, :end_time, :note)
    end
  end
end
