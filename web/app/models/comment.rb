class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  enum :status, { pending: 0, approved: 1, rejected: 2, flagged: 3 }, validate: true

  validates :body, presence: true
  validates :status, presence: true

  scope :approved, -> { where(status: :approved) }
  scope :flagged, -> { where(status: :flagged) }
  scope :visible, -> { approved }
end
