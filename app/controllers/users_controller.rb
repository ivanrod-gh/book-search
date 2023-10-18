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
    render json: Services::UserBooksShow.new(params, current_user).call
  end
end
