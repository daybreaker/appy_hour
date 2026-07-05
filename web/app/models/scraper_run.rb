# == Schema Information
#
# Table name: scraper_runs
#
#  id         :bigint           not null, primary key
#  notes      :text
#  raw_data   :jsonb
#  result     :integer          default("success"), not null
#  run_at     :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  venue_id   :bigint           not null
#
# Indexes
#
#  index_scraper_runs_on_result    (result)
#  index_scraper_runs_on_run_at    (run_at)
#  index_scraper_runs_on_venue_id  (venue_id)
#
# Foreign Keys
#
#  fk_rails_...  (venue_id => venues.id)
#
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
