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
