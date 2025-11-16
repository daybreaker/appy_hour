# == Schema Information
#
# Table name: menus
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(TRUE), not null
#  description    :text
#  effective_from :date
#  effective_to   :date
#  name           :string           not null
#  priority       :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  venue_id       :bigint           not null
#
# Indexes
#
#  index_menus_on_effective_from_and_effective_to   (effective_from,effective_to)
#  index_menus_on_venue_id                          (venue_id)
#  index_menus_on_venue_id_and_active_and_priority  (venue_id,active,priority)
#
# Foreign Keys
#
#  fk_rails_...  (venue_id => venues.id)
#
class Menu < ApplicationRecord
  belongs_to :venue
  has_many :hours, as: :schedulable, dependent: :destroy
  has_many :menu_item_deals, dependent: :destroy

  validates :name, presence: true

  scope :active, -> { where(active: true) }
  scope :effective_on, ->(date) {
    where("(effective_from IS NULL OR effective_from <= ?) AND (effective_to IS NULL OR effective_to >= ?)", date, date)
  }

  # Menus that are live at local time (join Hours with :menu kind)
  scope :live_at, ->(wday, tod) {
    joins(:hours).where(hours: { kind: Hour.kinds[:menu] })
      .where("hours.days_of_week @> ARRAY[?]::int[]", wday)
      .where(<<~SQL, tod: tod)
        (
          hours.overnight = false AND hours.opens_at <= :tod AND :tod < hours.closes_at
        ) OR (
          hours.overnight = true AND ( :tod >= hours.opens_at OR :tod < hours.closes_at )
        )
      SQL
  }
end
