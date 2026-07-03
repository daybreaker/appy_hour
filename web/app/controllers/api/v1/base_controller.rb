module Api
  module V1
    class BaseController < ActionController::API
      include CanCan::ControllerAdditions

      before_action :authenticate_api_user!

      rescue_from CanCan::AccessDenied do |exception|
        render json: { error: exception.message }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Not found" }, status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |exception|
        render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      private

      def authenticate_api_user!
        authenticate_with_http_token do |token, _options|
          @current_user = User.find_by(api_token: token)
        end

        render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
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
