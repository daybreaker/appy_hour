class HappyHour < ApplicationRecord
  belongs_to :venue
  belongs_to :submitted_by, class_name: "User", optional: true
  belongs_to :approved_by, class_name: "User", optional: true

  has_many :happy_hour_days, dependent: :destroy
  has_many :ratings, as: :rateable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

  accepts_nested_attributes_for :happy_hour_days, allow_destroy: true,
    reject_if: ->(attrs) {
      all_day = ActiveModel::Type::Boolean.new.cast(attrs[:all_day])
      !all_day && (attrs[:start_time].blank? || attrs[:end_time].blank?)
    }

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2,
    flagged: 3,
    pending_deletion: 4,
    deleted: 5
  }, validate: true

  validates :venue, presence: true
  validates :status, presence: true
  validates :source_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                                   message: "must be a valid http(s) URL" }, allow_blank: true

  # Only enforced for user/staff submissions via the web form; the scraper
  # builds happy hours incrementally and may persist before days exist.
  validate :must_have_at_least_one_day, on: :submission

  scope :approved, -> { where(status: :approved) }
  scope :pending, -> { where(status: :pending) }
  scope :pending_deletion, -> { where(status: :pending_deletion) }
  scope :needs_review, -> { where(status: [ :pending, :pending_deletion, :flagged ]) }
  scope :visible, -> { where(status: :approved) }
  scope :on_day, ->(day_of_week) {
    joins(:happy_hour_days).where(happy_hour_days: { day_of_week: day_of_week }).distinct
  }

  def auto_approve!(approver)
    update!(status: :approved, approved_by: approver, approved_at: Time.current)
  end

  # Link to the actual happy hour menu (a page, IG post, etc.).
  # Falls back to the venue's main website when no specific source is set.
  def link
    source_url.presence || venue.website_url.presence
  end

  # True when the link points to the specific happy hour source rather than
  # just the venue's homepage — lets the UI label it accordingly.
  def specific_source?
    source_url.present?
  end

  private

  def must_have_at_least_one_day
    if happy_hour_days.reject(&:marked_for_destruction?).empty?
      errors.add(:base, "Add at least one day with a start and end time")
    end
  end
end
