module Scrapers
  # Finds social media profile links in a page by matching link hostnames.
  # Pure Nokogiri + URL recognition — no AI. Returns at most one link per
  # platform (first match wins), excluding share/intent URLs.
  class SocialLinkDetector
    # Ordered so twitter/x and facebook variants resolve to a single platform.
    PLATFORM_HOSTS = {
      instagram: %w[instagram.com],
      twitter:   %w[twitter.com x.com],
      facebook:  %w[facebook.com fb.com fb.me],
      tiktok:    %w[tiktok.com],
      youtube:   %w[youtube.com youtu.be],
      yelp:      %w[yelp.com],
      linkedin:  %w[linkedin.com]
    }.freeze

    # Paths that are share widgets / intents, not a venue's own profile.
    EXCLUDED_PATH_HINTS = %w[
      /sharer /share /intent/ /dialog/ /plugins/ /home /login /signup
    ].freeze

    Detected = Struct.new(:platform, :url, keyword_init: true)

    def self.detect(doc_or_html)
      new.detect(doc_or_html)
    end

    def detect(doc_or_html)
      doc = doc_or_html.is_a?(String) ? Nokogiri::HTML(doc_or_html) : doc_or_html
      found = {}

      doc.css("a[href]").each do |anchor|
        href = anchor["href"].to_s.strip
        next if href.blank?

        uri = safe_uri(href)
        next unless uri&.host

        platform = platform_for(uri.host)
        next unless platform
        next if excluded?(uri)
        next if found.key?(platform)

        found[platform] = Detected.new(platform: platform, url: normalize(uri))
      end

      found.values
    end

    private

    def safe_uri(href)
      uri = URI.parse(href)
      return nil unless uri.is_a?(URI::HTTP)
      uri
    rescue URI::Error
      nil
    end

    def platform_for(host)
      host = host.downcase.delete_prefix("www.")
      PLATFORM_HOSTS.each do |platform, hosts|
        return platform if hosts.any? { |h| host == h || host.end_with?(".#{h}") }
      end
      nil
    end

    def excluded?(uri)
      path = uri.path.to_s.downcase
      return true if path.blank? || path == "/" # bare domain, not a profile
      EXCLUDED_PATH_HINTS.any? { |hint| path.include?(hint) }
    end

    # Canonical form: scheme://host/path, no query or fragment, no trailing slash.
    def normalize(uri)
      host = uri.host.downcase.delete_prefix("www.")
      path = uri.path.sub(%r{/+\z}, "")
      "#{uri.scheme}://#{host}#{path}"
    end
  end
end
