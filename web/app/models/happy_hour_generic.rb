# == Schema Information
#
# Table name: happy_hour_generics
#
#  id             :bigint           not null, primary key
#  applies_to     :string
#  description    :text
#  discount_type  :integer
#  discount_value :decimal(, )
#  status         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  happy_hour_id  :bigint           not null
#
# Indexes
#
#  index_happy_hour_generics_on_happy_hour_id  (happy_hour_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_hour_id => happy_hours.id)
#
class HappyHourGeneric < ApplicationRecord
  belongs_to :happy_hour

  # Discounts are relative reductions only. A set price on a specific thing is
  # a HappyHourItem, not a discount.
  enum :discount_type, { percentage: 0, dollar_off: 1 }, validate: true
  enum :status, { pending: 0, approved: 1, rejected: 2, flagged: 3, pending_deletion: 4, deleted: 5 }, validate: true

  validates :applies_to, presence: true
  validates :discount_type, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  scope :approved, -> { where(status: :approved) }
  scope :visible, -> { approved }
end
