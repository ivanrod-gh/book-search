require 'rails_helper'

RSpec.describe Services::Searches::WithFilters do
  let(:params_with_genre) { {genre_filter: '1', genre_int_id: 'invalid'} }
  let(:params_with_start_date_added) do
    {
      'start_date_filter': '1',
      'start_date_added(2i)' => '99',
      'start_date_added(1i)' => '1'
    } 
  end
  let(:params_with_end_date_added) do
    {
      'end_date_filter': '1',
      'end_date_added(2i)' => '99',
      'end_date_added(1i)' => '1'
    } 
  end
  let(:warning_genre) { {"warning"=>{"genre"=>"does_not_exist"}} }
  let(:warning_start_date_added) { {"warning"=>{"date_added_data"=>{"start"=>"invalid"}}} }
  let(:warning_end_date_added) { {"warning"=>{"date_added_data"=>{"end"=>"invalid"}}} }
  let(:book) { create(:book) }
  let(:five_books) { create_list(:book, 5) }
  let(:params_without_page) { { param1: 1, param2: 2, param3: 3 } }
  let(:params_with_page) { { param1: 1, param2: 2, param3: 3, page: 2 } }
  let(:params_page_only) { { page: 2 } }
  let(:user) { create(:user) }
  let(:book) { create(:book) }
  let(:user_book) { create(:user_book, user: user, book: book) }
  let(:search) { create(:search, user: user) }

  it 'respond with warning if genre does not exist' do
    expect(Services::Searches::WithFilters.new(params_with_genre).call).to eq warning_genre
  end

  it 'respond with warning if start date added is invalid' do
    expect(Services::Searches::WithFilters.new(params_with_start_date_added).call).to eq warning_start_date_added
  end

  it 'respond with warning if end date added is invalid' do
    expect(Services::Searches::WithFilters.new(params_with_end_date_added).call).to eq warning_end_date_added
  end

  it 'respond with no books if no books found' do
    expect(Services::Searches::WithFilters.new({}).call.key?('books')).to eq false
  end

  it 'respond with books if found a book' do
    book
    expect(Services::Searches::WithFilters.new({}).call.key?('books')).to eq true
  end

  it 'book in respond is serialized' do
    book
    serializer = ActiveModelSerializers::SerializableResource
    expect((Services::Searches::WithFilters.new({}).call)['books'].first.class).to eq serializer
  end

  it 'respond with collection data if request has no page query' do
    five_books
    expect((Services::Searches::WithFilters.new({}).call).key?(:results)).to eq true
    expect((Services::Searches::WithFilters.new({}).call)[:results][:count]).to eq 5
    per_page = Services::Searches::WithFilters::PER_PAGE
    expect((Services::Searches::WithFilters.new({}).call)[:results][:per_page]).to eq per_page
  end

  it 'respond with no collection data if request has page query' do
    five_books
    expect((Services::Searches::WithFilters.new({page: 1}).call).key?(:results)).to eq false
  end

  it 'respond with full params data if request has nill page query' do
    expect((Services::Searches::WithFilters.new(params_without_page).call)[:params]).to eq params_without_page
  end

  it 'respond with page only params data if request has page query' do
    expect((Services::Searches::WithFilters.new(params_with_page).call)[:params]).to eq params_page_only
  end

  it 'respond with user data' do
    expect(Services::Searches::WithFilters.new({}).call.key?(:user)).to eq true
  end

  context 'if called from unauthorized user user data in respond' do
    it 'has no id, book_ids, searches_updated_at_and_id' do
      expect((Services::Searches::WithFilters.new({}).call)[:user].key?(:id)).to eq false
      expect((Services::Searches::WithFilters.new({}).call)[:user].key?(:book_ids)).to eq false
      expect((Services::Searches::WithFilters.new({}).call)[:user].key?(:searches_updated_at_and_id)).to eq false
    end
  end

  context 'if called from authorized user user data in respond' do
    it 'has id' do
      expect((Services::Searches::WithFilters.new({}, user).call)[:user].key?(:id)).to eq true
      expect((Services::Searches::WithFilters.new({}, user).call)[:user][:id]).to eq user.id
    end

    it 'has book_ids' do
      user_book
      expect((Services::Searches::WithFilters.new({}, user).call)[:user].key?(:book_ids)).to eq true
      expect((Services::Searches::WithFilters.new({}, user).call)[:user][:book_ids]).to eq user.books.ids
    end

    it 'has searches_updated_at_and_id' do
      search
      searches_data = [{id: search.id, updated_at: search.updated_at.to_s}]
      expect((Services::Searches::WithFilters.new({}, user).call)[:user].key?(:searches_updated_at_and_id)).to eq true
      expect(
        (Services::Searches::WithFilters.new({}, user).call)[:user][:searches_updated_at_and_id]
      ).to eq searches_data
    end
  end
end
