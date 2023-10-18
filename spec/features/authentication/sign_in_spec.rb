require 'rails_helper'

feature 'User can sign in', %q{
  In order to use additional application features
  As an unauthenticated user
  I'd like to be able to sign in
} do
  background do
    visit root_path
    click_link(href: '/users/sign_in')
  end

  given(:user) { create(:user) }

  describe 'Registered user' do
    before do
      confirm(user)
      find(:xpath, "//input[@id='user_email']").set(user.email)
      find(:xpath, "//input[@id='user_password']").set(user.password)
      find(:xpath, "//input[@type='submit']").click
    end

    scenario 'tries to sign in' do
      expect(page).to have_content I18n.t('devise.sessions.signed_in')
    end

    scenario 'tries to sign in again' do
      visit new_user_session_path

      expect(page).to have_content I18n.t('devise.failure.already_authenticated')
    end
  end
  
  scenario 'Unregistered user tries to sign in with errors' do
    find(:xpath, "//input[@id='user_email']").set('some mail')
    find(:xpath, "//input[@id='user_password']").set('some password')
    find(:xpath, "//input[@type='submit']").click
    
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: I18n.t('activerecord.attributes.user.email')
  end
end

