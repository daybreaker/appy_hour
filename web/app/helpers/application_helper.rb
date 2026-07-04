module ApplicationHelper
  DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
  DAY_ABBR = %w[Sun Mon Tue Wed Thu Fri Sat].freeze

  def day_name(day_of_week)
    DAY_NAMES[day_of_week]
  end

  def day_abbr(day_of_week)
    DAY_ABBR[day_of_week]
  end

  def format_time_range(start_time, end_time)
    "#{start_time.strftime('%-l:%M %p')} – #{end_time.strftime('%-l:%M %p')}"
  end

  def generic_deal_label(deal)
    case deal.discount_type
    when "percentage" then "#{deal.discount_value.to_i}% off #{deal.applies_to}"
    when "dollar_off" then "$#{deal.discount_value.to_f.round(2)} off #{deal.applies_to}"
    when "fixed_price" then "#{deal.applies_to} for $#{deal.discount_value.to_f.round(2)}"
    else deal.applies_to
    end
  end

  # Admin destroy path for a deal, resolved by its type.
  def admin_deal_path(happy_hour, deal)
    case deal
    when HappyHourGeneric then admin_happy_hour_generic_deal_path(happy_hour, deal)
    when HappyHourItem then admin_happy_hour_item_deal_path(happy_hour, deal)
    when HappyHourBogo then admin_happy_hour_bogo_deal_path(happy_hour, deal)
    end
  end

  # One-line human summary for any deal type.
  def deal_summary(deal)
    case deal
    when HappyHourGeneric then generic_deal_label(deal)
    when HappyHourBogo then bogo_deal_label(deal)
    when HappyHourItem
      price = "$#{deal.happy_hour_price.to_f.round(2)}"
      orig = deal.original_price.present? ? " (was $#{deal.original_price.to_f.round(2)})" : ""
      "#{deal.name} — #{price}#{orig}"
    end
  end

  def bogo_deal_label(deal)
    get = case deal.get_discount_type
          when "free" then "get #{deal.get_quantity} free"
          when "percentage" then "get #{deal.get_quantity} at #{deal.get_discount_value.to_i}% off"
          when "dollar_off" then "get #{deal.get_quantity} at $#{deal.get_discount_value.to_f.round(2)} off"
          end
    "Buy #{deal.buy_quantity} #{deal.item_name}, #{get}"
  end
end
