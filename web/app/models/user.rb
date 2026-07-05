# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  api_token              :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("user"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_api_token             (api_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
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

  before_create :generate_api_token

  def staff?
    editor? || admin?
  end

  def regenerate_api_token!
    update!(api_token: generate_token)
  end

  private

  def generate_api_token
    self.api_token = generate_token
  end

  def generate_token
    loop do
      token = SecureRandom.urlsafe_base64(32)
      break token unless User.exists?(api_token: token)
    end
  end
end
