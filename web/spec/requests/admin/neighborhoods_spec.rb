require "rails_helper"

RSpec.describe "Admin::Neighborhoods", type: :request do
  let(:admin) { create(:user, role: :admin) }

  before { sign_in admin }

  describe "GET /admin/neighborhoods" do
    it "lists neighborhoods" do
      create(:neighborhood, name: "Ohio City", slug: "cleveland-ohio-city")
      create(:neighborhood, name: "Tremont", slug: "cleveland-tremont")
      get admin_neighborhoods_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ohio City")
      expect(response.body).to include("Tremont")
    end

    it "searches by name" do
      create(:neighborhood, name: "Ohio City", slug: "cleveland-ohio-city")
      create(:neighborhood, name: "Tremont", slug: "cleveland-tremont")
      get admin_neighborhoods_path(q: "Ohio")
      expect(response.body).to include("Ohio City")
      expect(response.body).not_to include("Tremont")
    end
  end

  describe "GET new and edit forms" do
    it "renders the new form" do
      get new_admin_neighborhood_path
      expect(response).to have_http_status(:ok)
    end

    it "renders the edit form" do
      neighborhood = create(:neighborhood)
      get edit_admin_neighborhood_path(neighborhood)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/neighborhoods" do
    it "creates a neighborhood and redirects" do
      expect {
        post admin_neighborhoods_path, params: { neighborhood: { name: "Detroit Shoreway", city: "Cleveland" } }
      }.to change(Neighborhood, :count).by(1)
      expect(response).to redirect_to(admin_neighborhoods_path)
    end

    it "auto-generates the slug when blank" do
      post admin_neighborhoods_path, params: { neighborhood: { name: "Ohio City", city: "Cleveland" } }
      expect(Neighborhood.last.slug).to eq("cleveland-ohio-city")
    end

    it "re-renders on invalid input" do
      post admin_neighborhoods_path, params: { neighborhood: { name: "", city: "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(Neighborhood.count).to eq(0)
    end
  end

  describe "PATCH /admin/neighborhoods/:id" do
    let!(:neighborhood) { create(:neighborhood, name: "Old Name", city: "Cleveland") }

    it "updates attributes" do
      patch admin_neighborhood_path(neighborhood), params: { neighborhood: { name: "New Name" } }
      expect(neighborhood.reload.name).to eq("New Name")
      expect(response).to redirect_to(admin_neighborhoods_path)
    end
  end

  describe "DELETE /admin/neighborhoods/:id" do
    it "deletes the neighborhood and unassigns its venues" do
      neighborhood = create(:neighborhood)
      venue = create(:venue, neighborhood: neighborhood)

      expect {
        delete admin_neighborhood_path(neighborhood)
      }.to change(Neighborhood, :count).by(-1)

      expect(venue.reload.neighborhood_id).to be_nil
    end
  end
end
