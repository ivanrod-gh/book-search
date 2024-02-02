require 'rails_helper'

RSpec.describe Services::Users::AccessToken do
  let(:user) { create(:user) }

  it 'create application and access token for user-caller' do
    Services::Users::AccessToken.new(user).call
    expect(Doorkeeper::Application.count).to eq 1
    expect(Doorkeeper::AccessToken.count).to eq 1
    expect(Doorkeeper::AccessToken.first.resource_owner_id).to eq user.id
  end

  it 'only one application and only one access token may exist after multiple calls' do
    Services::Users::AccessToken.new(user).call
    Services::Users::AccessToken.new(user).call
    Services::Users::AccessToken.new(user).call
    expect(Doorkeeper::Application.count).to eq 1
    expect(Doorkeeper::AccessToken.count).to eq 1
  end

  it 'destroy old access token in case of calling new access token' do
    Services::Users::AccessToken.new(user).call
    old_access_token_id = Doorkeeper::AccessToken.first.id
    Services::Users::AccessToken.new(user).call
    new_access_token_id = Doorkeeper::AccessToken.first.id
    expect(Doorkeeper::AccessToken.exists?(old_access_token_id)).to eq false
    expect(Doorkeeper::AccessToken.exists?(new_access_token_id)).to eq true
  end
end
