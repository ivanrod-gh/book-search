# frozen_string_literal: true

module Services
  class FindForOauth
    attr_reader :auth

    def initialize(auth)
      @auth = auth
    end

    def call
      find_user
    end

    private

    def find_user
      return nil unless auth.provider && auth.uid && auth.info[:email]

      authorization = Authorization.find_by(provider: auth.provider.to_s, uid: auth.uid.to_s)
      return authorization.user unless authorization.nil?

      user = confirmed_user(auth)
      user.authorizations.create(provider: auth.provider, uid: auth.uid)
      user
    end

    def confirmed_user(auth)
      email = auth.info[:email]
      user = User.find_by(email: email)
      return user unless user.nil?

      password = Devise.friendly_token[0, 20]
      user = User.new(email: email, password: password, password_confirmation: password)
      user.skip_confirmation!
      user.save
      user
    end
  end
end
