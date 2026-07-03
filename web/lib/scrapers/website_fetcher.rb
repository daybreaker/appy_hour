module Scrapers
  # Fetches a venue website and extracts readable text plus candidate
  # "menu" / "happy hour" links. Network and parsing failures are surfaced
  # as nil / empty results rather than raised, so the orchestrator can record
  # a ScraperRun and move on.
  class WebsiteFetcher
    USER_AGENT = "AppyHourBot/1.0 (+https://appyhour.example.com)"
    MENU_KEYWORDS = /happy\s*hour|menu|specials|drinks?|deals?/i
    MAX_TEXT_LENGTH = 20_000

    Result = Struct.new(:html, :text, :menu_links, :error, keyword_init: true) do
      def failed? = error.present?
    end

    def initialize(connection: nil)
      @connection = connection || build_connection
    end

    def fetch(url)
      return Result.new(error: "blank url") if url.blank?

      response = @connection.get(url)
      return Result.new(error: "http #{response.status}") unless response.success?

      html = response.body.to_s
      doc = Nokogiri::HTML(html)

      Result.new(
        html: html,
        text: extract_text(doc),
        menu_links: menu_links(doc, url)
      )
    rescue Faraday::Error => e
      Result.new(error: "faraday: #{e.message}")
    rescue StandardError => e
      Result.new(error: "#{e.class}: #{e.message}")
    end

    private

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
        next unless text.match?(MENU_KEYWORDS) || href.match?(MENU_KEYWORDS)

        absolutize(href, base)
      end.uniq.first(10)
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
        f.headers["User-Agent"] = USER_AGENT
        f.options.timeout = 10
        f.options.open_timeout = 5
      end
    end
  end
end
