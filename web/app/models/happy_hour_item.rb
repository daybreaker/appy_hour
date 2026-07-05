# == Schema Information
#
# Table name: happy_hour_items
#
#  id               :bigint           not null, primary key
#  category         :string
#  description      :text
#  happy_hour_price :decimal(, )
#  name             :string
#  original_price   :decimal(, )
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  happy_hour_id    :bigint           not null
#
# Indexes
#
#  index_happy_hour_items_on_happy_hour_id  (happy_hour_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_hour_id => happy_hours.id)
#
class HappyHourItem < ApplicationRecord
  belongs_to :happy_hour

  enum :status, { pending: 0, approved: 1, rejected: 2, flagged: 3, pending_deletion: 4, deleted: 5 }, validate: true

  validates :name, presence: true
  validates :happy_hour_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  scope :approved, -> { where(status: :approved) }
  scope :visible, -> { approved }
  scope :drinks, -> { where(category: "drink") }
  scope :food, -> { where(category: "food") }
end
