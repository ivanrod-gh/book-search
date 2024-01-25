class Api::V1::ProfilesController < ApplicationController
  # skip_before_action :authenticate_user!
  skip_authorization_check
  before_action :doorkeeper_authorize!

  def me
    render json: current_resource_user
  end
  
  private
  
  def current_resource_user
    @current_resource_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
