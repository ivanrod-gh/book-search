require 'rails_helper'

feature 'User can obtain API access', %q{
  In order to work with API
  As an authentcated user
  I'd like to be able to get API access token
} do
  given(:user) { create(:user) }

  describe 'Authenticated user' do
    before { sign_in(user) }

    scenario 'tries to get access token for API' do
      visit(manage_api_users_path)
      click_on 'Запросить код доступа'

      within '.access-token-itself' do
        expect(page).to have_content Doorkeeper::AccessToken.first.token
      end
    end
  end
end
