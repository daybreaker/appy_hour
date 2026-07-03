require "rails_helper"

RSpec.describe SocialLink, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:venue) }
  end

  describe "validations" do
    subject { build(:social_link) }

    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_uniqueness_of(:url).scoped_to(:venue_id) }
    it { is_expected.to define_enum_for(:platform).with_values(instagram: 0, twitter: 1, facebook: 2, tiktok: 3, youtube: 4, yelp: 5, linkedin: 6, other: 7) }

    it "rejects a non-url" do
      expect(build(:social_link, url: "not-a-url")).not_to be_valid
    end

    it "allows the same url on different venues" do
      create(:social_link, url: "https://instagram.com/shared")
      other = build(:social_link, url: "https://instagram.com/shared")
      expect(other).to be_valid
    end
  end

  describe "#platform_label" do
    it "renders X (Twitter) for twitter" do
      expect(build(:social_link, platform: :twitter).platform_label).to eq("X (Twitter)")
    end

    it "titleizes other platforms" do
      expect(build(:social_link, platform: :instagram).platform_label).to eq("Instagram")
    end
  end
end
