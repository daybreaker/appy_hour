module Api
  module V1
    class SocialLinkSerializer < Blueprinter::Base
      identifier :id
      fields :platform, :handle, :url
    end
  end
end
