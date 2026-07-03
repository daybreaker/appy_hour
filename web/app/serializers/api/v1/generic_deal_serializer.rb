module Api
  module V1
    class GenericDealSerializer < Blueprinter::Base
      identifier :id
      field(:type) { "generic" }
      fields :applies_to, :discount_type, :description
      field :discount_value do |deal|
        deal.discount_value&.to_f
      end
    end
  end
end
