module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json
        wrap_parameters format: []
        before_action { request.session_options[:skip] = true }

        # POST /api/v1/session
        def create
          email = params.dig(:user, :email).to_s
          password = params.dig(:user, :password).to_s

          # Devise's DB auth lookup (respects case-insensitive keys)
          resource = User.find_for_database_authentication(email: email)

          if resource&.valid_password?(password)
            # sessionless sign-in to trigger devise-jwt
            sign_in(:user, resource, store: false)

            token, _payload = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil)
            response.set_header('Authorization', "Bearer #{token}")

            render json: {
              user: { id: resource.id, email: resource.email, admin: resource.try(:admin) }
            }, status: :ok
          else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
          end
        end

        # DELETE /api/v1/session
        def destroy
          sign_out(resource_name)
          head :no_content
        end
      end
    end
  end
end
