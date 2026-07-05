# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  body             :text
#  commentable_type :string           not null
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  commentable_id   :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_comments_on_commentable  (commentable_type,commentable_id)
#  index_comments_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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
