class HappyHourGeneric < ApplicationRecord
  belongs_to :happy_hour

  enum :discount_type, { percentage: 0, dollar_off: 1, fixed_price: 2 }, validate: true
  enum :status, { pending: 0, approved: 1, rejected: 2, flagged: 3, pending_deletion: 4, deleted: 5 }, validate: true

  validates :applies_to, presence: true
  validates :discount_type, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  scope :approved, -> { where(status: :approved) }
  scope :visible, -> { approved }
end
