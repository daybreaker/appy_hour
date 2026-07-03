class HappyHour < ApplicationRecord
  belongs_to :venue
  belongs_to :submitted_by, class_name: "User", optional: true
  belongs_to :approved_by, class_name: "User", optional: true

  has_many :happy_hour_days, dependent: :destroy
  has_many :ratings, as: :rateable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

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

  scope :approved, -> { where(status: :approved) }
  scope :pending, -> { where(status: :pending) }
  scope :pending_deletion, -> { where(status: :pending_deletion) }
  scope :needs_review, -> { where(status: [ :pending, :pending_deletion, :flagged ]) }
  scope :visible, -> { where(status: :approved) }

  def auto_approve!(approver)
    update!(status: :approved, approved_by: approver, approved_at: Time.current)
  end
end
