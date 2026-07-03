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

  validates :url, presence: true,
                  uniqueness: { scope: :venue_id },
                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                            message: "must be a valid http(s) URL" }

  # Human label for the platform (e.g. "X (Twitter)").
  def platform_label
    case platform
    when "twitter" then "X (Twitter)"
    else platform.titleize
    end
  end
end
