require "rails_helper"

RSpec.describe Scrapers::SocialLinkDetector do
  def detect(html)
    described_class.detect(html)
  end

  it "detects instagram, facebook, and twitter/x links" do
    html = <<~HTML
      <footer>
        <a href="https://www.instagram.com/joesbar/">IG</a>
        <a href="https://facebook.com/joesbar">FB</a>
        <a href="https://x.com/joesbar">X</a>
      </footer>
    HTML

    results = detect(html)
    by_platform = results.to_h { |r| [ r.platform, r.url ] }

    expect(by_platform[:instagram]).to eq("https://instagram.com/joesbar")
    expect(by_platform[:facebook]).to eq("https://facebook.com/joesbar")
    expect(by_platform[:twitter]).to eq("https://x.com/joesbar")
  end

  it "treats twitter.com and x.com as the same platform" do
    html = '<a href="https://twitter.com/joesbar">t</a>'
    expect(detect(html).first.platform).to eq(:twitter)
  end

  it "returns only one link per platform (first wins)" do
    html = <<~HTML
      <a href="https://instagram.com/first">1</a>
      <a href="https://instagram.com/second">2</a>
    HTML
    igs = detect(html).select { |r| r.platform == :instagram }
    expect(igs.size).to eq(1)
    expect(igs.first.url).to eq("https://instagram.com/first")
  end

  it "ignores facebook share/intent widgets" do
    html = <<~HTML
      <a href="https://www.facebook.com/sharer/sharer.php?u=x">Share</a>
      <a href="https://twitter.com/intent/tweet?text=hi">Tweet</a>
    HTML
    expect(detect(html)).to be_empty
  end

  it "ignores bare domains with no profile path" do
    html = '<a href="https://instagram.com">Instagram</a>'
    expect(detect(html)).to be_empty
  end

  it "ignores non-social and non-http links" do
    html = <<~HTML
      <a href="https://example.com/menu">Menu</a>
      <a href="mailto:hi@example.com">Email</a>
      <a href="tel:+12165551234">Call</a>
    HTML
    expect(detect(html)).to be_empty
  end

  it "detects tiktok, youtube, yelp, and linkedin" do
    html = <<~HTML
      <a href="https://tiktok.com/@joesbar">tt</a>
      <a href="https://youtube.com/@joesbar">yt</a>
      <a href="https://www.yelp.com/biz/joes-bar">yelp</a>
      <a href="https://linkedin.com/company/joes-bar">li</a>
    HTML
    expect(detect(html).map(&:platform)).to contain_exactly(:tiktok, :youtube, :yelp, :linkedin)
  end
end
