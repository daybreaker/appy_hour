class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  validates :reason, presence: true

  scope :unresolved, -> { where(resolved_at: nil) }
  scope :resolved, -> { where.not(resolved_at: nil) }

  def resolve!
    update!(resolved_at: Time.current)
  end
end
