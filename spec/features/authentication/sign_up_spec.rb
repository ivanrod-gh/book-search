require 'rails_helper'

feature 'User can sign up', %q{
  In order to use additional application features
  As an unauthenticated user
  I'd like to be able to enter my details data then sign in
} do
  background do
    visit root_path
    click_link(href: '/users/sign_up')
  end

  describe 'Unregistered user tries to sign up' do
    before do
      find(:xpath, "//input[@id='user_email']").set(attributes_for(:user)[:email])
      find(:xpath, "//input[@id='user_password']").set(attributes_for(:user)[:password])
      find(:xpath, "//input[@id='user_password_confirmation']").set(attributes_for(:user)[:password])
      find(:xpath, "//input[@type='submit']").click
    end

    scenario 'and sees message about email confirmation' do
      expect(page).to have_content I18n.t('devise.confirmations.send_instructions')
    end

    scenario 'confirms email and get access to application' do
      path_regex = /(?:"https?\:\/\/.*?)(\/.*?)(?:")/    
      email = ActionMailer::Base.deliveries.last
      path = email.body.match(path_regex)[1]
      visit(path)

      expect(page).to have_content I18n.t('devise.confirmations.confirmed')
    end
  end

  scenario 'Unregistered user tries to sign up with errors' do
    find(:xpath, "//input[@type='submit']").click

    expect(page).to have_content "#{I18n.t('activerecord.attributes.user.email')} #{I18n.t('activerecord.errors.messages.blank')}"
    expect(page).to have_content "#{I18n.t('activerecord.attributes.user.password')} #{I18n.t('activerecord.errors.messages.blank')}"
  end
end


