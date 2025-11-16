module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json
        before_action { request.session_options[:skip] = true }
        wrap_parameters format: []

        # override to avoid any sanitizer/wrapper weirdness
        def create
          user = User.new(sign_up_params)
          if user.save
            # ✅ sessionless sign-in so devise-jwt can dispatch without touching sessions
            sign_in(:user, user, store: false)

            # (optional safety net) also set the header yourself
            token, _ = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
            response.set_header 'Authorization', "Bearer #{token}"

            render json: { user: { id: user.id, email: user.email } }, status: :created
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end
