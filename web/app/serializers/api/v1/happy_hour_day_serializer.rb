module Api
  module V1
    # A day is now purely a schedule entry — the deals live on the happy hour.
    class HappyHourDaySerializer < Blueprinter::Base
      identifier :id
      fields :day_of_week, :specific_date, :all_day

      field :day_name do |day|
        day.day_name
      end

      field :start_time do |day|
        day.start_time&.strftime("%H:%M")
      end

      field :end_time do |day|
        day.end_time&.strftime("%H:%M")
      end
    end
  end
end
