require 'rails_helper'

RSpec.describe UserBooksController, type: :controller do
  let(:user) { create(:user) }
  let(:book) { create(:book) }
  let(:another_book) { create(:book) }
  let(:user_book) { create(:user_book, user: user, book: book) }
  let(:another_user_book) { create(:user_book, user: user, book: another_book) }

  describe 'if called from authorized user' do
    before { login(user) }

    it 'assign requested user book to @user_book' do
      post :create, params: { book_id: user_book.book_id }, format: :js
      expect(assigns(:user_book)).to eq user_book
    end
  end

  describe 'POST #create' do
    let(:respond) { { persisted: true } }

    before { login(user) }

    it 'does not create user book if it already exist' do
      user_book
      expect{ post :create, params: { book_id: user_book.book_id }, format: :js }.to change(UserBook, :count).by(0)
    end

    it 'respond as JSON if user book already exist' do
      post :create, params: { book_id: user_book.book_id }, format: :js
      expect(response.body).to eq respond.to_json
    end

    it 'create user book' do
      expect{ post :create, params: { book_id: user_book.book_id }, format: :js }.to change(UserBook, :count).by(1)
    end

    it 'respond as JSON after creating a user book' do
      post :create, params: { book_id: user_book.book_id }, format: :js
      expect(response.body).to eq respond.to_json
    end

    it 'respond with warning in case of arror during user book creation' do
      post :create, params: { book_id: 0 }, format: :js
      expect(response.body.include?('error')).to eq true
    end
  end

  describe 'DELETE #destroy' do
    let(:respond) { {} }

    before { login(user) }

    it 'does not destroy user book if it does not exist' do
      expect{ delete :destroy, params: { book_id: 0 }, format: :js }.to change(UserBook, :count).by(0)
    end

    it 'respond as JSON if user book does not exist' do
      delete :destroy, params: { book_id: 0 }, format: :js
      expect(response.body).to eq respond.to_json
    end

    it 'destroy user book' do
      user_book
      expect{ delete :destroy, params: { book_id: user_book.book_id }, format: :js }.to change(UserBook, :count).by(-1)
    end

    it 'respond as JSON after destroying a user book' do
      delete :destroy, params: { book_id: user_book.book_id }, format: :js
      expect(response.body).to eq respond.to_json
    end
  end

  describe 'DELETE #destroy_all' do
    let(:respond) { { all_destroyed: true } }

    before { login(user) }

    it 'destroy all user books' do
      user_book
      another_user_book
      expect{ delete :destroy_all, format: :js }.to change(UserBook, :count).by(-2)
    end

    it 'respond as JSON after destroying all user books' do
      user_book
      another_user_book
      delete :destroy_all, format: :js
      expect(response.body).to eq respond.to_json
    end
  end

  describe 'GET #send_to_mail' do
    before { login(user) }

    it 'calls BookShelfDownloadJob with current_user = user-caller' do
      expect(BookShelfDownloadJob).to receive(:perform_later).with(user)
      get :send_to_mail, format: :js
    end
  end
end
