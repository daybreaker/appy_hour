require "rails_helper"

# These specs do NOT launch Chrome — they cover the non-browser branches.
# End-to-end rendering / gate-dismissal is verified with live runs.
RSpec.describe Scrapers::BrowserFetcher do
  let(:browser) { instance_double(Ferrum::Browser) }
  let(:http) { instance_double(Scrapers::WebsiteFetcher) }
  subject(:fetcher) { described_class.new(browser: browser, http: http) }

  it "returns a failed result for a blank url without touching the browser" do
    expect(fetcher.fetch(nil)).to be_failed
    expect(browser).not_to have_received(:create_page) if browser.respond_to?(:create_page)
  end

  it "delegates PDF urls to the HTTP fetcher (Chrome can't hand us PDF text)" do
    pdf_result = Scrapers::WebsiteFetcher::Result.new(text: "Happy Hour", menu_links: [], social_links: [])
    expect(http).to receive(:fetch).with("https://x.com/menu.pdf").and_return(pdf_result)

    result = fetcher.fetch("https://x.com/menu.pdf")
    expect(result.text).to eq("Happy Hour")
  end
end
