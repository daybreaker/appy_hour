require "rails_helper"

RSpec.describe Scrapers::HappyHourExtractor do
  # Fake stands in for Scrapers::ClaudeClient — no real API calls.
  let(:claude) { instance_double(Scrapers::ClaudeClient) }
  subject(:extractor) { described_class.new(claude: claude) }

  let(:found_json) do
    {
      has_happy_hour: true,
      notes: "Weekday specials",
      days: [
        { day_of_week: 3, start_time: "16:00", end_time: "18:00",
          generic_deals: [ { applies_to: "drafts", discount_type: "percentage", discount_value: 25 } ] }
      ]
    }.to_json
  end

  describe "#extract" do
    it "returns the parsed hash when a happy hour is found" do
      allow(claude).to receive(:complete).and_return(found_json)

      result = extractor.extract("some website text")

      expect(result["has_happy_hour"]).to be true
      expect(result["days"].first["start_time"]).to eq("16:00")
    end

    it "passes the system prompt and page text to Claude" do
      allow(claude).to receive(:complete).and_return(found_json)
      extractor.extract("MENU TEXT HERE")
      expect(claude).to have_received(:complete).with(
        hash_including(system: described_class::SYSTEM_PROMPT, prompt: a_string_including("MENU TEXT HERE"))
      )
    end

    it "returns nil when the model reports no happy hour" do
      allow(claude).to receive(:complete).and_return({ has_happy_hour: false, days: [] }.to_json)
      expect(extractor.extract("text")).to be_nil
    end

    it "tolerates JSON wrapped in prose or fences" do
      allow(claude).to receive(:complete).and_return("Here you go:\n```json\n#{found_json}\n```")
      expect(extractor.extract("text")).to be_a(Hash)
    end

    it "returns nil on unparseable output" do
      allow(claude).to receive(:complete).and_return("I could not find anything useful.")
      expect(extractor.extract("text")).to be_nil
    end

    it "returns nil for blank input without calling Claude" do
      expect(extractor.extract("")).to be_nil
      expect(claude).not_to have_received(:complete) if claude.respond_to?(:complete)
    end
  end
end
