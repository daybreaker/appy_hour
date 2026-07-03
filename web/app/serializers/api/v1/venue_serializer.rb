module Api
  module V1
    class VenueSerializer < Blueprinter::Base
      identifier :id
      fields :name, :address, :city, :zip_code, :phone, :website_url

      field :latitude do |venue|
        venue.latitude
      end

      field :longitude do |venue|
        venue.longitude
      end

      association :neighborhood, blueprint: NeighborhoodSerializer

      view :detail do
        association :happy_hours, blueprint: HappyHourSerializer do |venue|
          venue.happy_hours.approved
        end
      end
    end
  end
end
