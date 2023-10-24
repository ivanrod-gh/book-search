require 'rails_helper'

RSpec.describe Services::FindForOauth do
  let!(:user) { create(:user) }
  subject { Services::FindForOauth.new(auth) }

  context 'user already has authorization' do
    let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '12345', info: { email: 'new@user.email' }) }
    
    it 'returns the user' do
      user.authorizations.create(provider: 'github', uid: '12345')
      expect(subject.call).to eq user
    end
  end
  
  context 'user has not authorization' do
    context 'user already exists' do
      let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '12345', info: { email: user.email })}
      
      it 'does not create new user' do
        expect{ subject.call }.not_to change(User, :count)
      end
      
      it 'create authorization for user' do
        expect{ subject.call }.to change(user.authorizations, :count).by(1)
      end
      
      it 'create authorization with provider and uid' do
        user = subject.call
        authorization = user.authorizations.first
        
        expect(authorization.provider).to eq auth.provider
        expect(authorization.uid).to eq auth.uid
      end
      
      it 'returns the user' do
        expect(subject.call).to eq user
      end
    end
    
    context 'user does not exist' do
      let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '12345', info: { email: 'new@user.email' })}
      
      it 'create new user' do
        expect{ subject.call }.to change(User, :count).by(1)
      end
      
      it 'returns new user' do
        expect(subject.call).to be_a(User)
      end
      
      it 'fills user email' do
        user = subject.call
        expect(user.email).to eq auth.info[:email]
      end
      
      it 'creates authorization for user' do
        user = subject.call
        expect(user.authorizations).not_to be_empty
      end
      
      it 'creates authorization with provider and uid' do
        authorization = subject.call.authorizations.first
      
        expect(authorization.provider).to eq auth.provider
        expect(authorization.uid).to eq auth.uid
      end
    end
  end

  context 'response data is not enough' do
    let(:wrong_auth) { OmniAuth::AuthHash.new }

    it 'returns nil' do
      expect(Services::FindForOauth.new(wrong_auth).call).to eq nil
    end
  end
end
