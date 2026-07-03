require "rails_helper"

RSpec.describe HappyHour, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:venue) }
    it { is_expected.to belong_to(:submitted_by).class_name("User").optional }
    it { is_expected.to belong_to(:approved_by).class_name("User").optional }
    it { is_expected.to have_many(:happy_hour_days).dependent(:destroy) }
    it { is_expected.to have_many(:ratings) }
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:reports) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, approved: 1, rejected: 2, flagged: 3, pending_deletion: 4, deleted: 5) }
  end

  describe "scopes" do
    let!(:approved) { create(:happy_hour, status: :approved) }
    let!(:pending) { create(:happy_hour, status: :pending) }
    let!(:flagged) { create(:happy_hour, status: :flagged) }

    it ".approved returns only approved happy hours" do
      expect(HappyHour.approved).to contain_exactly(approved)
    end

    it ".pending returns only pending happy hours" do
      expect(HappyHour.pending).to contain_exactly(pending)
    end

    it ".needs_review returns pending, pending_deletion, and flagged" do
      expect(HappyHour.needs_review).to contain_exactly(pending, flagged)
    end
  end

  describe "source_url validation" do
    it "allows a blank source_url" do
      expect(build(:happy_hour, source_url: nil)).to be_valid
    end

    it "accepts a valid http(s) url" do
      expect(build(:happy_hour, source_url: "https://bar.com/happy-hour")).to be_valid
    end

    it "rejects a non-url string" do
      expect(build(:happy_hour, source_url: "not a url")).not_to be_valid
    end
  end

  describe "#link" do
    it "returns the source_url when present" do
      venue = build(:venue, website_url: "https://venue.com")
      happy_hour = build(:happy_hour, venue: venue, source_url: "https://venue.com/hh-menu")
      expect(happy_hour.link).to eq("https://venue.com/hh-menu")
    end

    it "falls back to the venue website when source_url is blank" do
      venue = build(:venue, website_url: "https://venue.com")
      happy_hour = build(:happy_hour, venue: venue, source_url: nil)
      expect(happy_hour.link).to eq("https://venue.com")
    end

    it "returns nil when neither is present" do
      venue = build(:venue, website_url: nil)
      happy_hour = build(:happy_hour, venue: venue, source_url: nil)
      expect(happy_hour.link).to be_nil
    end
  end

  describe "#specific_source?" do
    it "is true only when source_url is set" do
      expect(build(:happy_hour, source_url: "https://x.com/hh").specific_source?).to be true
      expect(build(:happy_hour, source_url: nil).specific_source?).to be false
    end
  end

  describe "#auto_approve!" do
    it "sets status to approved and records the approver" do
      approver = create(:user, role: :admin)
      happy_hour = create(:happy_hour, status: :pending)
      happy_hour.auto_approve!(approver)
      expect(happy_hour.reload.status).to eq("approved")
      expect(happy_hour.approved_by).to eq(approver)
      expect(happy_hour.approved_at).to be_present
    end
  end
end
