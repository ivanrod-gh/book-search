module FeatureHelpers
  def confirm(user)
    user.confirm
  end

  def sign_in(user)
    confirm(user) unless user.confirmed_at
    visit new_user_session_path
    find(:xpath, "//input[@id='user_email']").set(user.email)
    find(:xpath, "//input[@id='user_password']").set(user.password)
    find(:xpath, "//input[@type='submit']").click
  end

  def sign_out
    click_link(href: '/users/sign_in')
  end
end
