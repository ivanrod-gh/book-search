require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  describe 'POST #books_show' do
    let(:parameter) { 'value' }
    let(:service) { double('Services::Users::BooksShow') }
    let(:controller_params) do
      ActionController::Parameters.new(
        "parameter"=>"value",
        "format"=>"js",
        "controller"=>"users",
        "action"=>"books_show"
      )
    end
    let(:respond) { double("{test: 'results'}") }

    context 'called from authorized user' do
      before { login(user) }

      it 'calls BooksShow service with current_user = user-caller' do
        allow(service).to receive(:call)
        expect(Services::Users::BooksShow).to receive(:new).with(controller_params, user).and_return(service)
        post :books_show, params: { parameter: parameter }, format: :js
      end

      it 'calls BooksShow service with current_user and renders respond as JSON' do
        allow(service).to receive(:call)
        expect(Services::Users::BooksShow).to receive(:new).with(controller_params, user).and_return(service)
        expect(service).to receive(:call).and_return(respond)
        post :books_show, params: { parameter: parameter }, format: :js
        expect(response.body).to eq respond.to_json
      end
    end
  end

  describe 'POST #access_token' do
    let(:service) { double('Services::Users::AccessToken') }

    context 'called from authorized user' do
      before { login(user) }

      it 'calls AccessToken service with current_user = user-caller' do
        allow(service).to receive(:call)
        expect(Services::Users::AccessToken).to receive(:new).with(user).and_return(service)
        post :access_token
      end

      it 'redirect to manage api users path' do
        post :access_token
        expect(response).to redirect_to manage_api_users_path
      end
    end
  end
end
