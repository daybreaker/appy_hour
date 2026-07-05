# == Schema Information
#
# Table name: happy_hour_days
#
#  id            :bigint           not null, primary key
#  all_day       :boolean          default(FALSE), not null
#  day_of_week   :integer
#  end_time      :time
#  note          :string
#  specific_date :date
#  start_time    :time
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  happy_hour_id :bigint           not null
#
# Indexes
#
#  index_happy_hour_days_on_happy_hour_id  (happy_hour_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_hour_id => happy_hours.id)
#
FactoryBot.define do
  factory :happy_hour_day do
    association :happy_hour
    day_of_week { 1 } # Monday
    start_time { "16:00" }
    end_time { "18:00" }
    specific_date { nil }
  end
end
