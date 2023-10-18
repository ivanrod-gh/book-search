module ControllerHelpers
  def login(user)
    @request.env['devise.mapping'] = Devise.mappings[:user]
    user.confirm unless user.confirmed_at
    sign_in(user)
  end
end
