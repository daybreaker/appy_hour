module Api
  module V1
    class BogoDealSerializer < Blueprinter::Base
      identifier :id
      field(:type) { "bogo" }
      fields :buy_quantity, :get_quantity, :get_discount_type, :applies_to, :item_name, :description
      field :get_discount_value do |deal|
        deal.get_discount_value&.to_f
      end
    end
  end
end
