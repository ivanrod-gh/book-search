require 'rails_helper'

RSpec.describe OauthCallbacksController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe '#github' do
    let(:oauth_data) {{ 'provider' => 'github', 'uid' => 123 }}
    let(:oauth_hash) { OmniAuth::AuthHash.new(provider: 'github') }
    let(:service) { double('Services::FindForOauth') }
    
    it 'finds user from oauth data' do
      allow(request.env).to receive(:[]).and_call_original
      allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)
      expect(Services::FindForOauth).to receive(:new).with(oauth_data).and_return(service)
      expect(service).to receive(:call)
      get :github
    end
    
    context 'user exist' do
      let!(:user) do
        user = create(:user)
        login(user)
        user
      end
      
      before do
        allow(Services::FindForOauth).to receive(:new).and_return(service)
        allow(service).to receive(:call).and_return(user)
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_hash)
        get :github
      end
      
      it 'login user' do
        expect(subject.current_user).to eq user
      end
      
      it 'redirects to root path' do
        expect(response).to redirect_to root_path
      end
    end
    
    context 'user does not exist' do
      before do
        allow(Services::FindForOauth).to receive(:new).and_return(service)
        allow(service).to receive(:call)
        get :github
      end
      
      it 'does not login user' do
        expect(subject.current_user).not_to be
      end
      
      it 'redirects to root path' do
        expect(response).to redirect_to root_path
      end
    end
  end
end
