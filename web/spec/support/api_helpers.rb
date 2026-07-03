module ApiHelpers
  # Bearer token auth header for API request specs.
  def auth_headers(user)
    { "Authorization" => "Bearer #{user.api_token}" }
  end

  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
