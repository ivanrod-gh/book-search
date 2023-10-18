require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  describe 'POST #books_show' do
    let(:parameter) { 'value' }
    let(:service) { double('Services::UserBooksShow') }
    let(:controller_params) do
      ActionController::Parameters.new(
        "parameter"=>"value",
        "format"=>"js",
        "controller"=>"users",
        "action"=>"books_show"
      )
    end
    let(:respond) { double("{test: 'results'}") }

    describe 'then called from authorized user' do
      before { login(user) }

      it 'calls UserBooksShow with current_user = user-caller' do
        allow(service).to receive(:call)
        expect(Services::UserBooksShow).to receive(:new).with(controller_params, user)
                                                                           .and_return(service)
        post :books_show, params: { parameter: parameter }, format: :js
      end

      it 'calls UserBooksShow service with current_user and renders respond as JSON' do
        allow(service).to receive(:call)
        expect(Services::UserBooksShow).to receive(:new).with(controller_params, user).and_return(service)
        expect(service).to receive(:call).and_return(respond)
        post :books_show, params: { parameter: parameter }, format: :js
        expect(response.body).to eq respond.to_json
      end
    end
  end
end
