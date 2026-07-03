module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_api_user!, only: [ :create ]

      def create
        user = User.find_by(email: params[:email].to_s.downcase)

        if user&.valid_password?(params[:password])
          render json: UserSerializer.render_as_hash(user, view: :with_token), status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # Logout invalidates the current token by rotating it.
      def destroy
        current_user.regenerate_api_token!
        head :no_content
      end
    end
  end
end
