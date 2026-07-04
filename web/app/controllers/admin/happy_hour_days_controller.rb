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

    # Creates one day per selected weekday, all sharing the same time / all-day
    # / note. The "quick add" alternative to adding days one at a time.
    def bulk
      dows = Array(params[:days_of_week]).reject(&:blank?).map(&:to_i).uniq.select { |d| (0..6).cover?(d) }
      attrs = bulk_day_params

      if dows.empty?
        @day = @happy_hour.happy_hour_days.new(attrs)
        @day.errors.add(:base, "Select at least one day")
        return render_bulk_form(:unprocessable_entity)
      end

      # All days share the same attributes, so validating one is enough.
      sample = @happy_hour.happy_hour_days.new(attrs.merge(day_of_week: dows.first))
      unless sample.valid?
        @day = sample
        return render_bulk_form(:unprocessable_entity)
      end

      created = dows.map { |dow| @happy_hour.happy_hour_days.create!(attrs.merge(day_of_week: dow)) }

      render turbo_stream: [
        *created.map { |day|
          turbo_stream.append("happy_hour_#{@happy_hour.id}_days",
            partial: "admin/happy_hours/day", locals: { day: day })
        },
        bulk_form_stream(@happy_hour.happy_hour_days.new)
      ]
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

    def bulk_day_params
      params.fetch(:happy_hour_day, {}).permit(:all_day, :start_time, :end_time, :note)
    end

    def bulk_form_stream(day)
      turbo_stream.replace("happy_hour_#{@happy_hour.id}_bulk_day_form",
        partial: "admin/happy_hours/bulk_day_form", locals: { happy_hour: @happy_hour, day: day })
    end

    def render_bulk_form(status)
      render turbo_stream: bulk_form_stream(@day), status: status
    end
  end
end
