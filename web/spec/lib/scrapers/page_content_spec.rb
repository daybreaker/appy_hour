require "rails_helper"

RSpec.describe Scrapers::PageContent do
  describe ".text_from_html" do
    it "strips scripts/styles and collapses whitespace" do
      html = "<html><style>.x{}</style><body><script>var a=1</script><h1>Joe's</h1>  <p>Cold beer</p></body></html>"
      text = described_class.text_from_html(html)
      expect(text).to include("Joe's", "Cold beer")
      expect(text).not_to include("var a=1")
    end
  end

  describe ".links_from_html" do
    let(:html) do
      <<~HTML
        <a href="/happy-hour">HH</a>
        <a href="/menus/summer.pdf">Download</a>
        <a href="/about">About</a>
        <a href="https://other.com/x">External</a>
      HTML
    end

    it "keeps keyword and PDF links, drops unrelated ones (narrow mode)" do
      links = described_class.links_from_html(html, "https://joes.com/")
      expect(links).to include("https://joes.com/happy-hour", "https://joes.com/menus/summer.pdf")
      expect(links).not_to include("https://joes.com/about")
    end

    it "keeps same-domain non-keyword links in broad mode (for splash/enter pages)" do
      links = described_class.links_from_html(html, "https://joes.com/", broad: true)
      expect(links).to include("https://joes.com/about")
      expect(links).not_to include("https://other.com/x") # different domain
    end
  end

  describe ".pdf?" do
    it "detects PDFs by content type or extension" do
      expect(described_class.pdf?("https://x.com/menu.pdf", nil)).to be true
      expect(described_class.pdf?("https://x.com/menu.pdf?v=04202026", nil)).to be true # query after .pdf
      expect(described_class.pdf?("https://x.com/menu", "application/pdf")).to be true
      expect(described_class.pdf?("https://x.com/menu", "text/html")).to be false
    end
  end

  describe ".text_from_pdf" do
    it "returns empty string for unreadable bytes rather than raising" do
      expect(described_class.text_from_pdf("not a pdf")).to eq("")
    end
  end
end
