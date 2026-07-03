module Scrapers
  # Turns the extractor's normalized Hash into a HappyHour with its days and
  # deals. Everything is created with status :pending so it lands in the admin
  # approval queue — the scraper never publishes directly.
  class HappyHourPersister
    GENERIC_DISCOUNT_TYPES = HappyHourGeneric.discount_types.keys.freeze
    BOGO_DISCOUNT_TYPES = HappyHourBogo.get_discount_types.keys.freeze

    def initialize(venue)
      @venue = venue
    end

    # Returns the created HappyHour, or nil when the data contains no usable days.
    def persist(extracted)
      days = Array(extracted["days"]).select { |d| valid_day?(d) }
      return nil if days.empty?

      HappyHour.transaction do
        happy_hour = @venue.happy_hours.create!(
          status: :pending,
          notes: extracted["notes"].presence,
          source_url: extracted["source_url"].presence
        )

        days.each { |day_data| build_day(happy_hour, day_data) }
        happy_hour
      end
    end

    private

    def valid_day?(day)
      day.is_a?(Hash) &&
        (0..6).cover?(day["day_of_week"].to_i) &&
        day["start_time"].present? &&
        day["end_time"].present?
    end

    def build_day(happy_hour, day_data)
      day = happy_hour.happy_hour_days.create!(
        day_of_week: day_data["day_of_week"].to_i,
        start_time: day_data["start_time"],
        end_time: day_data["end_time"]
      )

      Array(day_data["generic_deals"]).each { |d| build_generic(day, d) }
      Array(day_data["item_deals"]).each { |d| build_item(day, d) }
      Array(day_data["bogo_deals"]).each { |d| build_bogo(day, d) }
    end

    def build_generic(day, deal)
      type = deal["discount_type"].to_s
      return unless GENERIC_DISCOUNT_TYPES.include?(type)
      return if deal["applies_to"].blank? || deal["discount_value"].blank?

      day.happy_hour_generics.create!(
        status: :pending,
        applies_to: deal["applies_to"],
        discount_type: type,
        discount_value: deal["discount_value"],
        description: deal["description"].presence
      )
    end

    def build_item(day, deal)
      return if deal["name"].blank? || deal["happy_hour_price"].blank?

      day.happy_hour_items.create!(
        status: :pending,
        name: deal["name"],
        category: deal["category"].presence,
        original_price: deal["original_price"].presence,
        happy_hour_price: deal["happy_hour_price"],
        description: deal["description"].presence
      )
    end

    def build_bogo(day, deal)
      type = deal["get_discount_type"].to_s
      return unless BOGO_DISCOUNT_TYPES.include?(type)
      return if deal["applies_to"].blank?

      day.happy_hour_bogos.create!(
        status: :pending,
        buy_quantity: deal["buy_quantity"] || 1,
        get_quantity: deal["get_quantity"] || 1,
        get_discount_type: type,
        get_discount_value: deal["get_discount_value"].presence,
        applies_to: deal["applies_to"],
        item_name: deal["item_name"].presence,
        description: deal["description"].presence
      )
    end
  end
end
