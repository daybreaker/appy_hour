class ApplicationController < ActionController::API
  before_action :authenticate_user!

  after_action :refresh_jwt_if_authenticated

  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password password_confirmation])
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[email password])
  end

  def refresh_jwt_if_authenticated
    return unless user_signed_in?

    encoder = Warden::JWTAuth::UserEncoder.new
    token, _payload = encoder.call(current_user, :user, nil)
    response.set_header 'Authorization', "Bearer #{token}"
  end
end
