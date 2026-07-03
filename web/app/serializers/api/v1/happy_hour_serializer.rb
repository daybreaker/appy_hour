module Api
  module V1
    class HappyHourSerializer < Blueprinter::Base
      identifier :id
      fields :notes, :status, :source_url

      # Resolved link (source_url or venue website fallback) for convenience.
      field :link do |happy_hour|
        happy_hour.link
      end

      association :days, blueprint: HappyHourDaySerializer do |happy_hour|
        happy_hour.happy_hour_days
      end
    end
  end
end
