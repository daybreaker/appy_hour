module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include CanCan::ControllerAdditions

      before_action :authenticate_api_user!

      rescue_from CanCan::AccessDenied do |exception|
        render json: { error: exception.message }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Not found" }, status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |exception|
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_content
      end

      private

      # Hard requirement: 401 if no valid token.
      def authenticate_api_user!
        authenticate_api_user
        render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
      end

      # Soft: sets current_user if a valid token is present, but does not fail.
      # Public endpoints use this so they can tailor responses to a signed-in user.
      def authenticate_api_user
        authenticate_with_http_token do |token, _options|
          @current_user = User.find_by(api_token: token)
        end
      end

      def current_user
        @current_user
      end

      def current_ability
        @current_ability ||= Ability.new(current_user)
      end
    end
  end
end
