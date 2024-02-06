require 'rails_helper'

describe 'Searches API', type: :request do
  let(:headers) {{ "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }}

  describe 'GET /api/v1/searches/full_text' do
    context 'unathorized' do
      it 'returns 401 status if there is no access token' do
        get '/api/v1/searches/full_text', headers: headers
        expect(response.status).to eq 401
      end
      
      it 'returns 401 status if access token is invalid' do
        get '/api/v1/searches/full_text', params: { access_token: '1234' }, headers: headers
        expect(response.status).to eq 401
      end
    end

    context 'authorized' do
      let(:user) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      it 'returns 200 status' do
        get '/api/v1/searches/full_text', params: { access_token: access_token.token, query: 'a' }, headers: headers
        expect(response).to be_successful
      end

      # No Unit tests for Sphinx search calls
    end
  end
end
