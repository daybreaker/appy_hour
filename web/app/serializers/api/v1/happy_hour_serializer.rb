module Api
  module V1
    class HappyHourSerializer < Blueprinter::Base
      identifier :id
      fields :notes, :status

      association :days, blueprint: HappyHourDaySerializer do |happy_hour|
        happy_hour.happy_hour_days
      end
    end
  end
end
