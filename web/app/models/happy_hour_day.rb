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
class HappyHourDay < ApplicationRecord
  belongs_to :happy_hour

  DAYS = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }, unless: :specific_date?
  validates :start_time, presence: true, unless: :all_day?
  validates :end_time, presence: true, unless: :all_day?
  validate :end_time_after_start_time

  before_validation :clear_times_when_all_day

  scope :for_day, ->(day) { where(day_of_week: day).or(where.not(specific_date: nil).where(specific_date: Date.current)) }
  scope :for_day_of_week, ->(day) { where(day_of_week: day, specific_date: nil) }
  scope :upcoming_special, -> { where.not(specific_date: nil).where(specific_date: Date.current..) }

  def day_name
    return specific_date.strftime("%A, %b %-d") if specific_date?
    DAYS[day_of_week]
  end

  # "All day" or the formatted time range, e.g. "4:00 PM – 6:00 PM".
  def hours_label
    return "All day" if all_day?

    "#{start_time.strftime('%-l:%M %p')} – #{end_time.strftime('%-l:%M %p')}"
  end

  private

  def clear_times_when_all_day
    return unless all_day?

    self.start_time = nil
    self.end_time = nil
  end

  def end_time_after_start_time
    return unless start_time && end_time
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
end
