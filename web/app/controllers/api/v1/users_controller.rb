module Api
  module V1
    class UsersController < BaseController
      def show
        render json: UserSerializer.render_as_hash(current_user), status: :ok
      end
    end
  end
end
