module Api
  module V1
    class UserSerializer < Blueprinter::Base
      identifier :id
      fields :email, :role

      # Only returned on login/registration so the client can store it.
      view :with_token do
        field :api_token
      end
    end
  end
end
