# == Schema Information
#
# Table name: neighborhoods
#
#  id         :bigint           not null, primary key
#  city       :string           not null
#  name       :string           not null
#  slug       :string           not null
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_neighborhoods_on_slug                     (slug) UNIQUE
#  index_neighborhoods_on_state_and_city_and_name  (state,city,name) UNIQUE
#
class Neighborhood < ApplicationRecord
  has_many :venues, dependent: :nullify

  validates :name, presence: true
  validates :city, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  scope :for_city, ->(city) { where(city: city) }
  scope :ordered, -> { order(:city, :name) }

  private

  def generate_slug
    self.slug = [ state, city, name ].compact_blank.join(" ").parameterize
  end
end
