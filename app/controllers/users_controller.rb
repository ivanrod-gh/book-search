# frozen_string_literal: true

class UsersController < ApplicationController
  def profile
    authorize! :profile, User
  end

  def books_shelf
    authorize! :books_shelf, User
  end

  def books_show
    authorize! :books_show, User
    render json: Services::Users::BooksShow.new(params, current_user).call
  end

  def manage_api
    authorize! :manage_api, User
    @access_token = Doorkeeper::AccessToken.find_by(resource_owner_id: current_user.id)
  end

  def access_token
    authorize! :access_token, User
    Services::Users::AccessToken.new(current_user).call
    redirect_to manage_api_users_path
  end
end
