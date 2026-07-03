module Api
  module V1
    class RegistrationsController < BaseController
      skip_before_action :authenticate_api_user!, only: [ :create ]

      def create
        user = User.new(sign_up_params)
        user.role = :user # never allow role escalation via the API

        if user.save
          render json: UserSerializer.render_as_hash(user, view: :with_token), status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def sign_up_params
        params.permit(:email, :password, :password_confirmation)
      end
    end
  end
end
