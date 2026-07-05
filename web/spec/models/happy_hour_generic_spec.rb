require 'rails_helper'

# == Schema Information
#
# Table name: happy_hour_generics
#
#  id             :bigint           not null, primary key
#  applies_to     :string
#  description    :text
#  discount_type  :integer
#  discount_value :decimal(, )
#  status         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  happy_hour_id  :bigint           not null
#
# Indexes
#
#  index_happy_hour_generics_on_happy_hour_id  (happy_hour_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_hour_id => happy_hours.id)
#
RSpec.describe HappyHourGeneric, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
