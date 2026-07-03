class HappyHourDay < ApplicationRecord
  belongs_to :happy_hour

  has_many :happy_hour_generics, dependent: :destroy
  has_many :happy_hour_items, dependent: :destroy
  has_many :happy_hour_bogos, dependent: :destroy

  DAYS = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }, unless: :specific_date?
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  scope :for_day, ->(day) { where(day_of_week: day).or(where.not(specific_date: nil).where(specific_date: Date.current)) }
  scope :for_day_of_week, ->(day) { where(day_of_week: day, specific_date: nil) }
  scope :upcoming_special, -> { where.not(specific_date: nil).where(specific_date: Date.current..) }

  def day_name
    return specific_date.strftime("%A, %b %-d") if specific_date?
    DAYS[day_of_week]
  end

  def deals
    happy_hour_generics.to_a + happy_hour_items.to_a + happy_hour_bogos.to_a
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
end
