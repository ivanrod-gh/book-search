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

  describe 'GET /api/v1/searches/with_filters' do
    context 'unathorized' do
      it 'returns 401 status if there is no access token' do
        get '/api/v1/searches/with_filters', headers: headers
        expect(response.status).to eq 401
      end
      
      it 'returns 401 status if access token is invalid' do
        get '/api/v1/searches/with_filters', params: { access_token: '1234' }, headers: headers
        expect(response.status).to eq 401
      end
    end

    context 'authorized' do
      let(:user) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }
      let(:first_added_book) { create(:book, :date_added_1987, name: 'first_added') }
      let(:second_added_book) { create(:book, :date_added_2111, name: 'second_added') }
      let(:last_added_book) { create(:book, :date_added_2123, name: 'last_added') }

      it 'returns 200 status' do
        get '/api/v1/searches/with_filters', params: { access_token: access_token.token }, headers: headers
        expect(response).to be_successful
      end

      it 'respond with no user data and no params data' do
        get '/api/v1/searches/with_filters', params: { access_token: access_token.token }, headers: headers
        expect(json.key?('user')).to eq false
        expect(json.key?('params')).to eq false
      end

      it 'respond with proper book when filter applied' do
        first_added_book
        second_added_book
        last_added_book
        get '/api/v1/searches/with_filters',
          params: {
            access_token: access_token.token,
            'start_date_added(2i)': '1',
            'start_date_added(1i)': '2000',
            'end_date_added(2i)': '1',
            'end_date_added(1i)': '2115',
          },
          headers: headers
        expect(json['books'].count).to eq 1
        expect(json['books'][0]['book']['name']).to eq second_added_book.name
      end
    end
  end
end
