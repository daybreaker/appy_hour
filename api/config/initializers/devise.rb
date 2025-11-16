require 'devise/orm/active_record'


Devise.setup do |config|
  config.mailer_sender = 'please-change-me@config-initializers-devise.com'
  config.navigational_formats = [] # no HTML redirects, JSON only
  config.parent_controller = 'ActionController::API'

  config.warden do |manager|
    manager.failure_app = JsonFailureApp
  end

  # ⬇️ Prevent Devise/Warden from writing to session
  config.skip_session_storage = [:http_auth, :params_auth, :token_auth]


  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.dig(:jwt, :secret) || ENV['JWT_SECRET']
    jwt.dispatch_requests = [
        ['POST', %r{\A/api/v1/session\z}], # login
      ['POST', %r{\A/api/v1/users\z}]    # signup
    ]
    # No revocation requests; we're stateless and use Null strategy
    jwt.expiration_time = 1.week # exp claim; we'll re-issue on each request
  end
end

