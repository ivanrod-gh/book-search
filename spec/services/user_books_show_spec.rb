require 'rails_helper'

RSpec.describe Services::Users::BooksShow do
  let(:user) { create(:user) }
  let(:user_book) { create(:user_book, user: user) }
  let(:five_user_books) { create_list(:user_book, 5, user: user) }

  it 'respond with no books if no user books found' do
    expect(Services::Users::BooksShow.new({}, user).call.key?('books')).to eq false
  end

  it 'respond with books if found a user book' do
    user_book
    expect(Services::Users::BooksShow.new({}, user).call.key?('books')).to eq true
  end

  it 'book in respond is serialized' do
    user_book
    serializer = ActiveModelSerializers::SerializableResource
    expect((Services::Users::BooksShow.new({}, user).call)['books'].first.class).to eq serializer
  end

  it 'respond with collection data' do
    five_user_books
    expect((Services::Users::BooksShow.new({}, user).call).key?(:results)).to eq true
    expect((Services::Users::BooksShow.new({}, user).call)[:results][:count]).to eq 5
    per_page = Services::Users::BooksShow::PER_PAGE
    expect((Services::Users::BooksShow.new({}, user).call)[:results][:per_page]).to eq per_page
  end

  it 'respond with page only params data' do
    user_book
    params_page = { page: 0 }
    expect((Services::Users::BooksShow.new({}, user).call)[:params]).to eq params_page
  end

  it 'respond with user data with user id' do
    expect(Services::Users::BooksShow.new({}, user).call.key?(:user)).to eq true
    expect((Services::Users::BooksShow.new({}, user).call)[:user].key?(:id)).to eq true
    expect((Services::Users::BooksShow.new({}, user).call)[:user][:id]).to eq user.id
  end
end
