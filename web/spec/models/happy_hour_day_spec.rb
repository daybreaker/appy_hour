require "rails_helper"

# == Schema Information
#
# Table name: happy_hour_days
#
#  id            :bigint           not null, primary key
#  all_day       :boolean          default(FALSE), not null
#  day_of_week   :integer
#  end_time      :time
#  note          :string
#  specific_date :date
#  start_time    :time
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  happy_hour_id :bigint           not null
#
# Indexes
#
#  index_happy_hour_days_on_happy_hour_id  (happy_hour_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_hour_id => happy_hours.id)
#
RSpec.describe HappyHourDay, type: :model do
  describe "validations" do
    it "requires start and end time by default" do
      day = build(:happy_hour_day, start_time: nil, end_time: nil, all_day: false)
      expect(day).not_to be_valid
      expect(day.errors[:start_time]).to be_present
    end

    it "rejects an end time before the start time" do
      day = build(:happy_hour_day, start_time: "18:00", end_time: "16:00")
      expect(day).not_to be_valid
    end
  end

  describe "all_day" do
    it "is valid without times when all_day is set" do
      day = build(:happy_hour_day, all_day: true, start_time: nil, end_time: nil)
      expect(day).to be_valid
    end

    it "clears any provided times when all_day is set" do
      day = create(:happy_hour_day, all_day: true, start_time: "16:00", end_time: "18:00")
      expect(day.start_time).to be_nil
      expect(day.end_time).to be_nil
    end
  end

  describe "#hours_label" do
    it "returns 'All day' when all_day" do
      expect(build(:happy_hour_day, all_day: true).hours_label).to eq("All day")
    end

    it "returns the formatted range otherwise" do
      day = build(:happy_hour_day, start_time: "16:00", end_time: "18:00", all_day: false)
      expect(day.hours_label).to eq("4:00 PM – 6:00 PM")
    end
  end
end
