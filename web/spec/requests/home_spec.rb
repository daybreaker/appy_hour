require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "renders successfully without login" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "shows venues with an approved happy hour on the requested day" do
      venue = create(:venue, name: "The Tavern")
      happy_hour = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 3)

      get root_path, params: { day: 3 }

      expect(response.body).to include("The Tavern")
    end

    it "does not show venues without a happy hour on that day" do
      venue = create(:venue, name: "No Deals Diner")
      happy_hour = create(:happy_hour, :approved, venue: venue)
      create(:happy_hour_day, happy_hour: happy_hour, day_of_week: 1)

      get root_path, params: { day: 3 }

      expect(response.body).not_to include("No Deals Diner")
    end

    it "filters by neighborhood" do
      hood = create(:neighborhood, name: "Ohio City")
      other_hood = create(:neighborhood, name: "Tremont")

      in_hood = create(:venue, name: "Market Garden", neighborhood: hood)
      out_hood = create(:venue, name: "South Side", neighborhood: other_hood)
      [ in_hood, out_hood ].each do |v|
        hh = create(:happy_hour, :approved, venue: v)
        create(:happy_hour_day, happy_hour: hh, day_of_week: 3)
      end

      get root_path, params: { day: 3, neighborhood_id: hood.id }

      expect(response.body).to include("Market Garden")
      expect(response.body).not_to include("South Side")
    end
  end
end
