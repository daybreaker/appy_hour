# == Schema Information
#
# Table name: happy_hour_bogos
#
#  id                 :bigint           not null, primary key
#  applies_to         :string
#  buy_quantity       :integer
#  description        :text
#  get_discount_type  :integer
#  get_discount_value :decimal(, )
#  get_quantity       :integer
#  item_name          :string
#  status             :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  happy_hour_id      :bigint           not null
#
# Indexes
#
#  index_happy_hour_bogos_on_happy_hour_id  (happy_hour_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_hour_id => happy_hours.id)
#
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
  # A name is required on hand entry; the scraper (default context) may omit it.
  validates :item_name, presence: true, on: :admin_entry

  validate :discount_value_required_unless_free

  scope :approved, -> { where(status: :approved) }
  scope :visible, -> { approved }

  private

  def discount_value_required_unless_free
    return if get_discount_type == "free" || get_discount_type.nil?
    errors.add(:get_discount_value, "is required for non-free BOGO deals") if get_discount_value.blank?
  end
end
