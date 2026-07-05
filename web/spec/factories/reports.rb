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
FactoryBot.define do
  factory :report do
    association :user
    reason { "Happy hour no longer offered" }
    notes { "" }
    resolved_at { nil }
    association :reportable, factory: :happy_hour
  end
end
