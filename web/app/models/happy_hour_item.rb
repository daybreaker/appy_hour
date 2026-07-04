class HappyHourItem < ApplicationRecord
  belongs_to :happy_hour

  enum :status, { pending: 0, approved: 1, rejected: 2, flagged: 3, pending_deletion: 4, deleted: 5 }, validate: true

  validates :name, presence: true
  validates :happy_hour_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
  # Required when entered by hand in the admin; the scraper (default context)
  # may not always capture a description.
  validates :description, presence: true, on: :admin_entry

  scope :approved, -> { where(status: :approved) }
  scope :visible, -> { approved }
  scope :drinks, -> { where(category: "drink") }
  scope :food, -> { where(category: "food") }
end
