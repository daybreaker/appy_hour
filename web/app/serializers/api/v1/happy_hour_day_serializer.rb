module Api
  module V1
    class HappyHourDaySerializer < Blueprinter::Base
      identifier :id
      fields :day_of_week, :specific_date

      field :day_name do |day|
        day.day_name
      end

      field :start_time do |day|
        day.start_time&.strftime("%H:%M")
      end

      field :end_time do |day|
        day.end_time&.strftime("%H:%M")
      end

      association :generic_deals, blueprint: GenericDealSerializer do |day|
        day.happy_hour_generics.select { |d| d.status == "approved" }
      end

      association :item_deals, blueprint: ItemDealSerializer do |day|
        day.happy_hour_items.select { |d| d.status == "approved" }
      end

      association :bogo_deals, blueprint: BogoDealSerializer do |day|
        day.happy_hour_bogos.select { |d| d.status == "approved" }
      end
    end
  end
end
