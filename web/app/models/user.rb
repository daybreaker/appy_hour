class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { user: 0, editor: 1, admin: 2 }, validate: true

  has_many :submitted_happy_hours, class_name: "HappyHour", foreign_key: :submitted_by_id,
           inverse_of: :submitted_by, dependent: :nullify
  has_many :approved_happy_hours, class_name: "HappyHour", foreign_key: :approved_by_id,
           inverse_of: :approved_by, dependent: :nullify
  has_many :favorite_venues, dependent: :destroy
  has_many :favorites, through: :favorite_venues, source: :venue
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :noticed_notifications, as: :recipient, dependent: :destroy,
           class_name: "Noticed::Notification"

  def staff?
    editor? || admin?
  end
end
