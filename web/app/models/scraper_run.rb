class ScraperRun < ApplicationRecord
  belongs_to :venue

  enum :result, {
    success: 0,
    happy_hour_found: 1,
    happy_hour_not_found: 2,
    parse_failed: 3,
    fetch_failed: 4
  }, validate: true

  validates :run_at, presence: true
  validates :result, presence: true

  scope :recent, -> { order(run_at: :desc) }
  scope :failed, -> { where(result: [ :parse_failed, :fetch_failed ]) }
end
