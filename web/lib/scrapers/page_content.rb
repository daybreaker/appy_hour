module Scrapers
  # Shared HTML/PDF text + link extraction, used by both the plain
  # WebsiteFetcher and the headless BrowserFetcher.
  module PageContent
    module_function

    MAX_TEXT_LENGTH = 20_000
    # Links worth following to find happy hour info.
    LINK_KEYWORDS = /happy\s*hour|menu|special|drink|food|deal|brewpub|taproom|\bpub\b|eat|dine|info|location|hour/i

    def text_from_html(html)
      doc = Nokogiri::HTML(html)
      doc.search("script, style, noscript, svg").remove
      doc.text.gsub(/\s+/, " ").strip.truncate(MAX_TEXT_LENGTH, omission: "")
    end

    # Candidate links to follow. With broad: true (headless mode) we also keep
    # same-domain links that don't match keywords — for splash / "enter" /
    # location pages whose links have no useful text (e.g. an image link to
    # info.php). Keyword/PDF matches are prioritized first.
    def links_from_html(html, base_url, limit: 6, broad: false)
      doc = Nokogiri::HTML(html)
      base = URI.parse(base_url) rescue nil

      keyword, other = [], []
      doc.css("a[href]").each do |a|
        href = a["href"].to_s.strip
        next if href.blank? || href.start_with?("#", "mailto:", "tel:", "javascript:")

        abs = absolutize(href, base)
        pdf = href.split("?").first.to_s.downcase.end_with?(".pdf")
        relevant = pdf || a.text.to_s.match?(LINK_KEYWORDS) || href.match?(LINK_KEYWORDS)

        if relevant
          keyword << abs
        elsif broad && same_domain?(abs, base)
          other << abs
        end
      end

      (keyword + other).uniq.first(limit)
    end

    def absolutize(href, base)
      return href if href.start_with?("http")
      return href unless base

      URI.join("#{base.scheme}://#{base.host}", href).to_s
    rescue URI::Error
      href
    end

    def same_domain?(url, base)
      return false unless base

      host = URI.parse(url).host rescue nil
      host.present? && host.sub(/\Awww\./, "") == base.host.to_s.sub(/\Awww\./, "")
    end

    def pdf?(url, content_type)
      content_type.to_s.include?("application/pdf") ||
        url.to_s.split("?").first.to_s.downcase.end_with?(".pdf")
    end

    def text_from_pdf(bytes)
      reader = PDF::Reader.new(StringIO.new(bytes))
      reader.pages.map(&:text).join(" ").gsub(/\s+/, " ").strip.truncate(MAX_TEXT_LENGTH, omission: "")
    rescue StandardError
      ""
    end
  end
end
