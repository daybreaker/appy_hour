require 'rails_helper'

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
RSpec.describe ScraperRun, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
