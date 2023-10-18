require 'rails_helper'

feature 'User can sign out', %q{
  In order to end session
  As an authenticated user
  I'd like to sign out
} do
  given(:user) { create(:user) }

  scenario 'Registered user tries to sign out' do
    sign_in(user)

    click_link(href: '/users/sign_out')

    expect(page).to have_content I18n.t('devise.sessions.signed_out')
  end

  scenario 'Unregistered user tries to sign out' do
    visit root_path

    expect(page).not_to have_link '/users/sign_out'
  end
end

