# frozen_string_literal: true

module Services
  module Users
    class AccessToken
      ACCESS_TOKEN_EXPIRES_IN = 43_200

      def initialize(user)
        @user = user
      end

      def call
        user_api_access(@user)
      end

      private

      def user_api_access(user)
        application = user_application(user)
        user_access_token(application, user)
      end

      def user_application(user)
        find_user_application(user) || new_user_application
      end

      def find_user_application(user)
        return false unless (access_token = Doorkeeper::AccessToken.find_by(resource_owner_id: user.id))

        Doorkeeper::Application.find_by(id: access_token.application_id)
      end

      def new_user_application
        Doorkeeper::Application.create(name: 'user_app', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob', scopes: 'public')
      end

      def user_access_token(application, user)
        Doorkeeper::AccessToken.where(resource_owner_id: user.id).destroy_all
        Doorkeeper::AccessToken.create_for(
          application: application,
          resource_owner: user,
          scopes: 'public',
          expires_in: ACCESS_TOKEN_EXPIRES_IN
        )
      end
    end
  end
end
