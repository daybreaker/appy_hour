module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json
        before_action { request.session_options[:skip] = true }
        wrap_parameters format: []

        def create
          self.resource = warden.authenticate!(auth_options)
          # ✅ sessionless sign-in
          sign_in(resource_name, resource, store: false)

          # (optional safety net) also set the header yourself
          token, _ = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil)
          response.set_header 'Authorization', "Bearer #{token}"

          respond_with(resource, {})
        end

        private

        def sign_in_params
          params.require(:user).permit(:email, :password)
        end

        def respond_with(resource, _opts = {})
          render json: { user: { id: resource.id, email: resource.email } }, status: :ok
        end

        def respond_to_on_destroy
          head :no_content
        end
      end
    end
  end
end
