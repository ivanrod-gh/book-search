require 'rails_helper'

feature 'User can see API access information', %q{
  In order to work with API
  As an authentcated user
  I'd like to be able to see information about my API access
} do
  given(:user) { create(:user) }
  given(:access_token) { create(:access_token, resource_owner_id: user.id) }
  given(:almost_expired_access_token) { create(:access_token, resource_owner_id: user.id, expires_in: 59) }
  given(:expired_access_token) { create(:access_token, resource_owner_id: user.id, expires_in: -1) }

  describe 'Authenticated user' do
    before { sign_in(user) }

    context 'tries to watch API access information' do
      scenario 'then no access token exists' do
        visit(manage_api_users_path)

        expect(page).not_to have_content 'Код доступа:'
      end

      scenario 'then access token is not expired' do
        access_token
        visit(manage_api_users_path)

        within '.access-token-itself' do
          expect(page).to have_content Doorkeeper::AccessToken.first.token
        end
        within '.access-token-expiration' do
          expect(page).to have_content 'нет'
        end
        within '.access-token-valid-for' do
          expect(page).to have_content '10'
        end
      end

      scenario 'then access token expiration time less then 60 seconds shows valid for 1 minute' do
        almost_expired_access_token
        visit(manage_api_users_path)

        within '.access-token-valid-for' do
          expect(page).to have_content '1'
        end
      end

      scenario 'then access token is expired' do
        expired_access_token
        visit(manage_api_users_path)

        within '.access-token-itself' do
          expect(page).to have_content Doorkeeper::AccessToken.first.token
        end
        within '.access-token-expiration' do
          expect(page).to have_content 'да'
        end
        within '.access-token-valid-for' do
          expect(page).to have_content '---'
        end
      end
    end
  end
end

