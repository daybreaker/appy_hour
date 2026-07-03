require "rails_helper"

RSpec.describe Scrapers::WebsiteFetcher do
  subject(:fetcher) { described_class.new }

  describe "#fetch" do
    let(:html) do
      <<~HTML
        <html><head><style>.x{}</style></head>
        <body>
          <script>var a = 1;</script>
          <h1>Joe's Bar</h1>
          <p>Come in for our great drinks.</p>
          <a href="/happy-hour">Happy Hour Menu</a>
          <a href="https://joesbar.com/food-menu">Food Menu</a>
          <a href="/about">About Us</a>
        </body></html>
      HTML
    end

    it "returns extracted text without script/style content" do
      stub_request(:get, "https://joesbar.com/").to_return(status: 200, body: html)

      result = fetcher.fetch("https://joesbar.com/")

      expect(result).not_to be_failed
      expect(result.text).to include("Joe's Bar")
      expect(result.text).to include("great drinks")
      expect(result.text).not_to include("var a = 1")
    end

    it "finds menu / happy hour links and absolutizes them" do
      stub_request(:get, "https://joesbar.com/").to_return(status: 200, body: html)

      result = fetcher.fetch("https://joesbar.com/")

      expect(result.menu_links).to include("https://joesbar.com/happy-hour")
      expect(result.menu_links).to include("https://joesbar.com/food-menu")
      expect(result.menu_links).not_to include(a_string_matching(/about/))
    end

    it "detects social links on the page" do
      social_html = <<~HTML
        <html><body>
          <a href="https://instagram.com/joesbar">IG</a>
          <a href="https://facebook.com/joesbar">FB</a>
        </body></html>
      HTML
      stub_request(:get, "https://joesbar.com/").to_return(status: 200, body: social_html)

      result = fetcher.fetch("https://joesbar.com/")

      expect(result.social_links.map(&:platform)).to contain_exactly(:instagram, :facebook)
    end

    it "returns a failed result on HTTP error" do
      stub_request(:get, "https://joesbar.com/").to_return(status: 500, body: "err")
      result = fetcher.fetch("https://joesbar.com/")
      expect(result).to be_failed
      expect(result.error).to include("500")
    end

    it "returns a failed result on connection failure" do
      stub_request(:get, "https://joesbar.com/").to_raise(Faraday::ConnectionFailed.new("boom"))
      result = fetcher.fetch("https://joesbar.com/")
      expect(result).to be_failed
    end

    it "returns a failed result for a blank url" do
      expect(fetcher.fetch(nil)).to be_failed
    end
  end
end
