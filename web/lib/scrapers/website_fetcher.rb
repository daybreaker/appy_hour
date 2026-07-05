require "pdf/reader"

module Scrapers
  # Fetches a venue website (HTML or PDF) and extracts readable text plus
  # candidate menu / info links to follow. Network and parsing failures are
  # surfaced as nil / empty results rather than raised, so the orchestrator can
  # record a ScraperRun and move on.
  class WebsiteFetcher
    USER_AGENT = "AppyHourBot/1.0 (+https://appyhour.example.com)"
    # Links worth following to find happy hour info — menus, specials, and the
    # common "landing" pages restaurants put hours/deals on.
    LINK_KEYWORDS = /happy\s*hour|menu|special|drink|food|deal|brewpub|taproom|\bpub\b|eat|dine/i
    MAX_TEXT_LENGTH = 20_000
    MAX_LINKS = 6

    Result = Struct.new(:html, :text, :menu_links, :social_links, :error, keyword_init: true) do
      def failed? = error.present?
    end

    def initialize(connection: nil)
      @connection = connection || build_connection
    end

    def fetch(url)
      return Result.new(error: "blank url") if url.blank?

      response = @connection.get(url)
      return Result.new(error: "http #{response.status}") unless response.success?

      body = response.body.to_s

      if pdf?(url, response.headers["content-type"])
        Result.new(html: nil, text: extract_pdf_text(body), menu_links: [], social_links: [])
      else
        doc = Nokogiri::HTML(body)
        Result.new(
          html: body,
          text: extract_text(doc),
          menu_links: menu_links(doc, url),
          social_links: SocialLinkDetector.detect(doc)
        )
      end
    rescue Faraday::Error => e
      Result.new(error: "faraday: #{e.message}")
    rescue StandardError => e
      Result.new(error: "#{e.class}: #{e.message}")
    end

    private

    def pdf?(url, content_type)
      content_type.to_s.include?("application/pdf") ||
        url.to_s.split("?").first.to_s.downcase.end_with?(".pdf")
    end

    def extract_pdf_text(bytes)
      reader = PDF::Reader.new(StringIO.new(bytes))
      text = reader.pages.map(&:text).join(" ")
      text.gsub(/\s+/, " ").strip.truncate(MAX_TEXT_LENGTH, omission: "")
    rescue StandardError
      "" # unreadable / encrypted PDF — treat as no text
    end

    def extract_text(doc)
      doc.search("script, style, noscript, svg").remove
      doc.text.gsub(/\s+/, " ").strip.truncate(MAX_TEXT_LENGTH, omission: "")
    end

    def menu_links(doc, base_url)
      base = URI.parse(base_url) rescue nil

      doc.css("a[href]").filter_map do |a|
        text = a.text.to_s.strip
        href = a["href"].to_s.strip
        next if href.blank?

        pdf = href.split("?").first.to_s.downcase.end_with?(".pdf")
        next unless pdf || text.match?(LINK_KEYWORDS) || href.match?(LINK_KEYWORDS)

        absolutize(href, base)
      end.uniq.first(MAX_LINKS)
    end

    def absolutize(href, base)
      return href if href.start_with?("http")
      return href unless base

      URI.join("#{base.scheme}://#{base.host}", href).to_s
    rescue URI::Error
      href
    end

    def build_connection
      Faraday.new do |f|
        f.request :retry, max: 2, interval: 0.5
        f.response :follow_redirects, limit: 5 # http->https and other 3xx
        f.headers["User-Agent"] = USER_AGENT
        f.options.timeout = 15
        f.options.open_timeout = 5
      end
    end
  end
end
