require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(user) }

  let(:venue) { create(:venue) }
  let(:happy_hour) { create(:happy_hour, :approved, venue: venue) }
  let(:pending_happy_hour) { create(:happy_hour, status: :pending, venue: venue) }

  context "when guest (not logged in)" do
    let(:user) { nil }

    it { is_expected.to be_able_to(:read, venue) }
    it { is_expected.to be_able_to(:read, happy_hour) }
    it { is_expected.not_to be_able_to(:create, HappyHour) }
    it { is_expected.not_to be_able_to(:create, Comment) }
    it { is_expected.not_to be_able_to(:create, Rating) }
    it { is_expected.not_to be_able_to(:manage, FavoriteVenue) }
  end

  context "when user role" do
    let(:user) { create(:user, role: :user) }
    let(:own_happy_hour) { create(:happy_hour, status: :pending, venue: venue, submitted_by: user) }
    let(:other_happy_hour) { create(:happy_hour, status: :pending, venue: venue) }
    let(:own_comment) { create(:comment, user: user, commentable: venue, status: :pending) }

    it { is_expected.to be_able_to(:read, venue) }
    it { is_expected.to be_able_to(:read, happy_hour) }
    it { is_expected.to be_able_to(:create, HappyHour) }
    it { is_expected.to be_able_to(:create, Comment) }
    it { is_expected.to be_able_to(:create, Rating) }
    it { is_expected.to be_able_to(:create, Report) }
    it { is_expected.to be_able_to(:manage, FavoriteVenue.new(user_id: user.id)) }

    it { is_expected.to be_able_to(:update, own_happy_hour) }
    it { is_expected.not_to be_able_to(:update, other_happy_hour) }
    it { is_expected.not_to be_able_to(:approve, pending_happy_hour) }
    it { is_expected.not_to be_able_to(:reject, pending_happy_hour) }
    it { is_expected.not_to be_able_to(:manage, FavoriteVenue.new(user_id: user.id + 1)) }
  end

  context "when editor role" do
    let(:user) { create(:user, role: :editor) }

    it { is_expected.to be_able_to(:read, :all) }
    it { is_expected.to be_able_to(:approve, pending_happy_hour) }
    it { is_expected.to be_able_to(:reject, pending_happy_hour) }
    it { is_expected.to be_able_to(:manage, venue) }
    it { is_expected.to be_able_to(:manage, pending_happy_hour) }
    it { is_expected.not_to be_able_to(:manage, User) }
  end

  context "when admin role" do
    let(:user) { create(:user, role: :admin) }

    it { is_expected.to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:approve, pending_happy_hour) }
  end
end
