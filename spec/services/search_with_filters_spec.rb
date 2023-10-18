require 'rails_helper'

RSpec.describe Services::SearchWithFilters do
  let(:params_with_genre) { {genre_filter: '1', genre_int_id: 'invalid'} }
  let(:params_with_start_date_added) { { 'start_date_filter': '1', 'start_date_added(1i)': 'invalid' } }
  let(:params_with_end_date_added) { { 'end_date_filter': '1', 'end_date_added(1i)': 'invalid' } }
  let(:warning_genre) { {"warning"=>{"genre"=>"does_not_exist"}} }
  let(:warning_start_date_added) { {"warning"=>{"date_added_data"=>{"start"=>"invalid"}}} }
  let(:warning_end_date_added) { {"warning"=>{"date_added_data"=>{"end"=>"invalid"}}} }
  let(:book) { create(:book) }
  let(:five_books) { create_list(:book, 5) }
  let(:params_without_page) { { param1: 1, param2: 2, param3: 3 } }
  let(:params_with_page) { { param1: 1, param2: 2, param3: 3, page: 2 } }
  let(:params_page_only) { { page: 2 } }

  it 'respond with warning if genre does not exist' do
    expect(Services::SearchWithFilters.new(params_with_genre).call).to eq warning_genre
  end

  it 'respond with warning if start date added is invalid' do
    expect(Services::SearchWithFilters.new(params_with_start_date_added).call).to eq warning_start_date_added
  end

  it 'respond with warning if end date added is invalid' do
    expect(Services::SearchWithFilters.new(params_with_end_date_added).call).to eq warning_end_date_added
  end

  it 'respond with no books if no books found' do
    expect(Services::SearchWithFilters.new({}).call.key?('books')).to eq false
  end

  it 'respond with books if found a book' do
    book
    expect(Services::SearchWithFilters.new({}).call.key?('books')).to eq true
  end

  it 'book in respond is serialized' do
    book
    serializer = ActiveModelSerializers::SerializableResource
    expect((Services::SearchWithFilters.new({}).call)['books'].first.class).to eq serializer
  end

  it 'respond with collection data if request has no page query' do
    five_books
    expect((Services::SearchWithFilters.new({}).call).key?(:results)).to eq true
    expect((Services::SearchWithFilters.new({}).call)[:results][:count]).to eq 5
    per_page = Services::SearchWithFilters::PER_PAGE
    expect((Services::SearchWithFilters.new({}).call)[:results][:per_page]).to eq per_page
  end

  it 'respond with no collection data if request has page query' do
    five_books
    expect((Services::SearchWithFilters.new({page: 1}).call).key?(:results)).to eq false
  end

  it 'respond with full params data if request has no page query' do
    expect((Services::SearchWithFilters.new(params_without_page).call)[:params]).to eq params_without_page
  end

  it 'respond with page only params data if request has page query' do
    expect((Services::SearchWithFilters.new(params_with_page).call)[:params]).to eq params_page_only
  end
end
