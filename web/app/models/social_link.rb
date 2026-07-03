class SocialLink < ApplicationRecord
  belongs_to :venue

  enum :platform, {
    instagram: 0,
    twitter: 1,
    facebook: 2,
    tiktok: 3,
    youtube: 4,
    yelp: 5,
    linkedin: 6,
    other: 7
  }, validate: true

  # The stored `url` is a platform's base + the account handle. Admins enter
  # just the handle (e.g. "joesbar"); the full URL is derived from these.
  URL_BASES = {
    "instagram" => "https://instagram.com/",
    "twitter"   => "https://x.com/",
    "facebook"  => "https://facebook.com/",
    "tiktok"    => "https://tiktok.com/@",
    "youtube"   => "https://youtube.com/@",
    "yelp"      => "https://yelp.com/biz/",
    "linkedin"  => "https://linkedin.com/company/"
  }.freeze

  # Display prefixes (no scheme) for form hints, e.g. "instagram.com/".
  DISPLAY_PREFIXES = URL_BASES.transform_values { |base| base.delete_prefix("https://") }.freeze

  validates :url, presence: true,
                  uniqueness: { scope: :venue_id },
                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                            message: "must be a valid http(s) URL" }

  before_validation :build_url_from_handle, if: -> { @handle_provided && @handle.present? }

  # Form-facing handle. Setter stores the cleaned handle; the URL is rebuilt in
  # a before_validation once platform is known. Getter falls back to deriving
  # the handle from the stored URL (for the edit form / scraped records).
  def handle=(value)
    @handle_provided = true
    @handle = value.to_s.strip.delete_prefix("@").presence
  end

  def handle
    @handle_provided ? @handle : extract_handle
  end

  def self.display_prefix(platform)
    DISPLAY_PREFIXES[platform.to_s]
  end

  # Human label for the platform (e.g. "X (Twitter)").
  def platform_label
    case platform
    when "twitter" then "X (Twitter)"
    else platform.titleize
    end
  end

  private

  def build_url_from_handle
    base = URL_BASES[platform]
    self.url = base ? "#{base}#{@handle}" : @handle
  end

  # Reverse of URL_BASES: pull the handle back out of a stored URL.
  def extract_handle
    return if url.blank?

    URI.parse(url).path.to_s
       .sub(%r{\A/}, "")
       .sub(%r{\A@}, "")
       .sub(%r{\Abiz/}, "")
       .sub(%r{\Acompany/}, "")
       .presence
  rescue URI::Error
    nil
  end
end
