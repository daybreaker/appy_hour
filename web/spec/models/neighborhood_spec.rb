require "rails_helper"

RSpec.describe Neighborhood, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:venues) }
  end

  describe "validations" do
    subject { build(:neighborhood) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  describe "slug auto-generation" do
    it "generates a slug from city and name before validation" do
      neighborhood = build(:neighborhood, name: "Ohio City", city: "Cleveland", slug: nil)
      neighborhood.valid?
      expect(neighborhood.slug).to eq("cleveland-ohio-city")
    end

    it "does not overwrite an existing slug" do
      neighborhood = build(:neighborhood, name: "Ohio City", city: "Cleveland", slug: "custom-slug")
      neighborhood.valid?
      expect(neighborhood.slug).to eq("custom-slug")
    end

    it "includes the state in the slug when present" do
      neighborhood = build(:neighborhood, name: "Ohio City", city: "Cleveland", state: "OH", slug: nil)
      neighborhood.valid?
      expect(neighborhood.slug).to eq("oh-cleveland-ohio-city")
    end
  end

  describe ".for_city" do
    it "returns neighborhoods in the given city" do
      cleveland = create(:neighborhood, city: "Cleveland")
      create(:neighborhood, city: "Columbus", name: "Short North", slug: "columbus-short-north")
      expect(Neighborhood.for_city("Cleveland")).to contain_exactly(cleveland)
    end
  end
end
