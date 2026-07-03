module Api
  module V1
    class ItemDealSerializer < Blueprinter::Base
      identifier :id
      field(:type) { "item" }
      fields :name, :category, :description
      field :original_price do |deal|
        deal.original_price&.to_f
      end
      field :happy_hour_price do |deal|
        deal.happy_hour_price&.to_f
      end
    end
  end
end
