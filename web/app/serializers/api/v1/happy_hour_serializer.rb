module Api
  module V1
    class HappyHourSerializer < Blueprinter::Base
      identifier :id
      fields :notes, :status, :source_url

      # Resolved link (source_url or venue website fallback) for convenience.
      field :link do |happy_hour|
        happy_hour.link
      end

      # When this menu runs.
      association :days, blueprint: HappyHourDaySerializer do |happy_hour|
        happy_hour.happy_hour_days
      end

      # The menu — deals apply across all of the days above.
      association :generic_deals, blueprint: GenericDealSerializer do |happy_hour|
        happy_hour.happy_hour_generics.select { |d| d.status == "approved" }
      end

      association :item_deals, blueprint: ItemDealSerializer do |happy_hour|
        happy_hour.happy_hour_items.select { |d| d.status == "approved" }
      end

      association :bogo_deals, blueprint: BogoDealSerializer do |happy_hour|
        happy_hour.happy_hour_bogos.select { |d| d.status == "approved" }
      end
    end
  end
end
