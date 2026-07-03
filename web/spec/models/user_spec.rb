require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:submitted_happy_hours).class_name("HappyHour") }
    it { is_expected.to have_many(:approved_happy_hours).class_name("HappyHour") }
    it { is_expected.to have_many(:favorite_venues).dependent(:destroy) }
    it { is_expected.to have_many(:favorites).through(:favorite_venues).source(:venue) }
    it { is_expected.to have_many(:ratings).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:reports).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to define_enum_for(:role).with_values(user: 0, editor: 1, admin: 2) }
  end

  describe "#staff?" do
    it "returns false for user role" do
      expect(build(:user, role: :user).staff?).to be false
    end

    it "returns true for editor role" do
      expect(build(:user, role: :editor).staff?).to be true
    end

    it "returns true for admin role" do
      expect(build(:user, role: :admin).staff?).to be true
    end
  end
end
