module ApplicationHelper
  DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
  DAY_ABBR = %w[Sun Mon Tue Wed Thu Fri Sat].freeze

  def day_name(day_of_week)
    DAY_NAMES[day_of_week]
  end

  # Venue ids the current user has favorited (memoized per request).
  def favorite_venue_ids
    @favorite_venue_ids ||=
      user_signed_in? ? current_user.favorite_venues.pluck(:venue_id).to_set : Set.new
  end

  def favorited?(venue)
    favorite_venue_ids.include?(venue.id)
  end

  def day_abbr(day_of_week)
    DAY_ABBR[day_of_week]
  end

  def format_time_range(start_time, end_time)
    "#{start_time.strftime('%-l:%M %p')} – #{end_time.strftime('%-l:%M %p')}"
  end

  # Always two decimals, e.g. "$9.00". Returns nil for blank amounts.
  def money(amount)
    return if amount.blank?
    number_to_currency(amount)
  end

  def generic_deal_label(deal)
    case deal.discount_type
    when "percentage" then "#{deal.discount_value.to_i}% off #{deal.applies_to}"
    when "dollar_off" then "#{money(deal.discount_value)} off #{deal.applies_to}"
    else deal.applies_to
    end
  end

  # Admin member path for a deal (GET=show, PATCH=update, DELETE=destroy),
  # resolved by its type.
  def admin_deal_path(happy_hour, deal)
    case deal
    when HappyHourGeneric then admin_happy_hour_generic_deal_path(happy_hour, deal)
    when HappyHourItem then admin_happy_hour_item_deal_path(happy_hour, deal)
    when HappyHourBogo then admin_happy_hour_bogo_deal_path(happy_hour, deal)
    end
  end

  def edit_admin_deal_path(happy_hour, deal)
    case deal
    when HappyHourGeneric then edit_admin_happy_hour_generic_deal_path(happy_hour, deal)
    when HappyHourItem then edit_admin_happy_hour_item_deal_path(happy_hour, deal)
    when HappyHourBogo then edit_admin_happy_hour_bogo_deal_path(happy_hour, deal)
    end
  end

  # Shared input-fields partial for a deal's add and edit forms.
  def deal_fields_partial(deal)
    case deal
    when HappyHourGeneric then "admin/deals/generic_fields"
    when HappyHourItem then "admin/deals/item_fields"
    when HappyHourBogo then "admin/deals/bogo_fields"
    end
  end

  # Short type badge for a deal. Items show their category (Food/Drink),
  # falling back to "Item" only when no category is set.
  def deal_type_label(deal)
    case deal
    when HappyHourBogo then "BOGO"
    when HappyHourItem then deal.category.presence&.capitalize || "Item"
    else deal.model_name.human.sub("Happy hour ", "")
    end
  end

  # One-line human summary for any deal type.
  def deal_summary(deal)
    case deal
    when HappyHourGeneric then generic_deal_label(deal)
    when HappyHourBogo then bogo_deal_label(deal)
    when HappyHourItem
      orig = deal.original_price.present? ? " (was #{money(deal.original_price)})" : ""
      "#{deal.name} — #{money(deal.happy_hour_price)}#{orig}"
    end
  end

  def bogo_deal_label(deal)
    get = case deal.get_discount_type
          when "free" then "get #{deal.get_quantity} free"
          when "percentage" then "get #{deal.get_quantity} at #{deal.get_discount_value.to_i}% off"
          when "dollar_off" then "get #{deal.get_quantity} at #{money(deal.get_discount_value)} off"
          end
    "Buy #{deal.buy_quantity} #{deal.item_name}, #{get}"
  end
end
