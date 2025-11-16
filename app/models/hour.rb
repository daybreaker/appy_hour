# == Schema Information
#
# Table name: hours
#
#  id               :bigint           not null, primary key
#  closes_at        :time             not null
#  days_of_week     :integer          default([]), not null, is an Array
#  effective_from   :date
#  effective_to     :date
#  kind             :integer          default(0), not null
#  note             :string
#  opens_at         :time             not null
#  overnight        :boolean          default(FALSE), not null
#  schedulable_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  schedulable_id   :bigint           not null
#
# Indexes
#
#  idx_hours_sched_kind         (schedulable_type,schedulable_id,kind)
#  index_hours_on_closes_at     (closes_at)
#  index_hours_on_days_of_week  (days_of_week) USING gin
#  index_hours_on_opens_at      (opens_at)
#  index_hours_on_schedulable   (schedulable_type,schedulable_id)
#
class Hour < ApplicationRecord
  belongs_to :schedulable, polymorphic: true

  enum :kind, { operating: 0, menu: 1 }

  validates :days_of_week, presence: true
  validates :opens_at, :closes_at, presence: true
  validate :non_negative_window

  scope :for_day, ->(wday) { where("days_of_week @> ARRAY[?]::int[]", wday) }

  # time-of-day string "HH:MM:SS" or Time#to_s(:db)
  scope :covers_time, ->(tod) {
    where(<<~SQL, tod: tod)
      (overnight = false AND opens_at <= :tod AND :tod < closes_at)
      OR
      (overnight = true  AND (:tod >= opens_at OR :tod < closes_at))
    SQL
  }

  def active_at?(tod, wday)
    days_of_week.include?(wday) &&
      ((!overnight && opens_at <= tod && tod < closes_at) ||
       (overnight && (tod >= opens_at || tod < closes_at)))
  end

  private

  def non_negative_window
    return if overnight
    if opens_at && closes_at && opens_at >= closes_at
      errors.add(:base, "opens_at must be before closes_at unless overnight")
    end
  end
end
