module Api
  module V1
    class NeighborhoodSerializer < Blueprinter::Base
      identifier :id
      fields :name, :city, :slug
    end
  end
end
