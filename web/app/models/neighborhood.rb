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
