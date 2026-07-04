class HappyHourBogo < ApplicationRecord
  belongs_to :happy_hour

  enum :get_discount_type, { free: 0, percentage: 1, dollar_off: 2 }, validate: true
  enum :status, { pending: 0, approved: 1, rejected: 2, flagged: 3, pending_deletion: 4, deleted: 5 }, validate: true

  validates :buy_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :get_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :get_discount_type, presence: true
  validates :get_discount_value, numericality: { greater_than: 0 }, allow_nil: true
  validates :applies_to, presence: true
  validates :status, presence: true
  # Required on hand entry; scraper (default context) may omit these.
  validates :item_name, presence: true, on: :admin_entry
  validates :description, presence: true, on: :admin_entry

  validate :discount_value_required_unless_free

  scope :approved, -> { where(status: :approved) }
  scope :visible, -> { approved }

  private

  def discount_value_required_unless_free
    return if get_discount_type == "free" || get_discount_type.nil?
    errors.add(:get_discount_value, "is required for non-free BOGO deals") if get_discount_value.blank?
  end
end
