# == Schema Information
#
# Table name: menu_item_deals
#
#  id                    :bigint           not null, primary key
#  active                :boolean          default(TRUE), not null
#  amount_off_cents      :integer
#  base_price_cents      :integer
#  bogo_buy_qty          :integer
#  bogo_get_qty          :integer
#  currency              :string           default("USD"), not null
#  deal_type             :integer          default(2), not null
#  effective_price_cents :integer
#  min_qty               :integer
#  name                  :string           not null
#  percent_off           :integer
#  price_cents           :integer
#  priority              :integer          default(0), not null
#  tags                  :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  menu_id               :bigint           not null
#  menu_item_id          :bigint           not null
#
# Indexes
#
#  idx_deals_menu_type_active_prio                 (menu_id,deal_type,active,priority)
#  index_menu_item_deals_on_effective_price_cents  (effective_price_cents)
#  index_menu_item_deals_on_menu_id                (menu_id)
#  index_menu_item_deals_on_menu_item_id           (menu_item_id)
#  index_menu_item_deals_on_tags                   (tags) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (menu_id => menus.id)
#  fk_rails_...  (menu_item_id => menu_items.id)
#
class MenuItemDeal < ApplicationRecord
  belongs_to :menu
  belongs_to :menu_item

  enum :deal_type, { bogo: 0, percent_off: 1, set_price: 2, amount_off: 3 }

  validates :name, presence: true
  validates :currency, presence: true
  validates :percent_off, inclusion: 0..100, allow_nil: true
  validate  :deal_fields_match_type
  validates :effective_price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :compute_effective_price

  scope :active, -> { where(active: true) }
  scope :by_category, ->(kinds) {
    joins(:menu_item).where(menu_items: { item_type: MenuItem.item_types.values_at(*Array(kinds)).compact })
  }
  scope :by_deal_type, ->(types) {
    where(deal_type: deal_types.values_at(*Array(types)).compact)
  }
  scope :ordered_for_display, -> {
    order(Arel.sql("priority DESC NULLS LAST"), :effective_price_cents, :name)
  }

  def context_base_cents
    base_price_cents.presence || menu_item.base_price_cents
  end

  private

  def compute_effective_price
    self.effective_price_cents = nil
    case deal_type&.to_sym
    when :set_price
      self.effective_price_cents = price_cents
    when :amount_off
      base = context_base_cents
      self.effective_price_cents = [0, (base.to_i - amount_off_cents.to_i)].max if base
    when :percent_off
      base = context_base_cents
      self.effective_price_cents = (base.to_i * (100 - percent_off.to_i) / 100.0).round if base
    when :bogo
      # leave nil; displayed as BOGO
    end
  end

  def deal_fields_match_type
    case deal_type&.to_sym
    when :set_price
      errors.add(:price_cents, "required") if price_cents.blank?
      %i[amount_off_cents percent_off bogo_buy_qty bogo_get_qty].each { |f| errors.add(f, "must be blank") if self.send(f).present? }
    when :amount_off
      errors.add(:amount_off_cents, "required") if amount_off_cents.blank?
    when :percent_off
      errors.add(:percent_off, "required") if percent_off.blank?
    when :bogo
      errors.add(:bogo_buy_qty, "required") if bogo_buy_qty.blank?
      errors.add(:bogo_get_qty, "required") if bogo_get_qty.blank?
    end
  end
end
