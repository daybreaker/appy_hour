# == Schema Information
#
# Table name: happy_hours
#
#  id              :bigint           not null, primary key
#  approved_at     :datetime
#  notes           :text
#  source_url      :string
#  status          :integer          default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  approved_by_id  :bigint
#  submitted_by_id :bigint
#  venue_id        :bigint           not null
#
# Indexes
#
#  index_happy_hours_on_approved_by_id   (approved_by_id)
#  index_happy_hours_on_status           (status)
#  index_happy_hours_on_submitted_by_id  (submitted_by_id)
#  index_happy_hours_on_venue_id         (venue_id)
#
# Foreign Keys
#
#  fk_rails_...  (approved_by_id => users.id)
#  fk_rails_...  (submitted_by_id => users.id)
#  fk_rails_...  (venue_id => venues.id)
#
FactoryBot.define do
  factory :happy_hour do
    association :venue
    status { :pending }
    notes { nil }
    approved_at { nil }
    submitted_by { nil }
    approved_by { nil }

    trait :approved do
      status { :approved }
      approved_at { Time.current }
      association :approved_by, factory: :user, role: :admin
    end

    trait :pending_deletion do
      status { :pending_deletion }
    end
  end
end
