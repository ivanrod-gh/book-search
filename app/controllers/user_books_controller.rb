# frozen_string_literal: true

class UserBooksController < ApplicationController
  before_action :find_user_book, only: %i[create destroy]

  def create
    authorize! :create, UserBook
    return render json: { persisted: true } unless @user_book.nil?

    user_book = current_user.user_books.create(book_id: params[:book_id])
    render json: (user_book.persisted? ? { persisted: true } : user_book.errors.messages)
  end

  def destroy
    authorize! :destroy, UserBook
    return render json: {} unless @user_book

    render json: (@user_book.destroy.persisted? ? { persisted: true } : {})
  end

  def destroy_all
    authorize! :destroy_all, UserBook
    render json: { all_destroyed: current_user.user_books.destroy_all.count.positive? }
  end

  def send_to_mail
    authorize! :send_to_mail, UserBook
    BookShelfDownloadJob.perform_later(current_user)
    render json: {}
  end

  private

  def find_user_book
    @user_book = current_user.user_books.find_by(book_id: params[:book_id])
  end
end
