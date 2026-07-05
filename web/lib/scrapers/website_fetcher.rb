require "pdf/reader"

module Scrapers
  # Plain HTTP fetch (no JS). Fast path — reads HTML or PDF and extracts text +
  # candidate links. Failures are returned as a failed Result, never raised.
  # For JS-rendered / gated sites, use BrowserFetcher instead.
  class WebsiteFetcher
    USER_AGENT = "AppyHourBot/1.0 (+https://appyhour.example.com)"

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

      if PageContent.pdf?(url, response.headers["content-type"])
        Result.new(html: nil, text: PageContent.text_from_pdf(body), menu_links: [], social_links: [])
      else
        Result.new(
          html: body,
          text: PageContent.text_from_html(body),
          menu_links: PageContent.links_from_html(body, url),
          social_links: SocialLinkDetector.detect(body)
        )
      end
    rescue Faraday::Error => e
      Result.new(error: "faraday: #{e.message}")
    rescue StandardError => e
      Result.new(error: "#{e.class}: #{e.message}")
    end

    private

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
