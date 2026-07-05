require 'rails_helper'

# == Schema Information
#
# Table name: reports
#
#  id              :bigint           not null, primary key
#  notes           :text
#  reason          :string
#  reportable_type :string           not null
#  resolved_at     :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  reportable_id   :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_reports_on_reportable  (reportable_type,reportable_id)
#  index_reports_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe Report, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
