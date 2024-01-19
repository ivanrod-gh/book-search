require 'rails_helper'

RSpec.describe Services::Searches::WithFiltersParametersSave, type: :service do
  let(:user) { create(:user) }
  let(:params_with_page) { ActionController::Parameters.new('page' => '2') }
  let(:params_with_genre_and_writing_year) do
    ActionController::Parameters.new(
      'genre_filter' => '1',
      'genre_int_id' => '5074',
      'writing_year_filter' => '1',
      'writing_year'=> '2005'
    )
  end

  let(:maximum_searches) do
    create_list(:search, Services::Searches::WithFiltersParametersSave::MAXIMUM_SEARCHES_COUNT, user: user)
  end

  context 'then called from authorized user' do
    it 'does not save request parameters if search have \'page\' in request params' do
      expect{ Services::Searches::WithFiltersParametersSave.new(params_with_page, user).call }.to change(Search, :count).by(0)
    end

    it 'save request parameters' do
      expect do
        Services::Searches::WithFiltersParametersSave.new(params_with_genre_and_writing_year, user).call 
      end.to change(Search, :count).by(1)
    end

    it 'update oldest search parameters if seaches count reaches maximum' do
      maximum_searches
      last_search = Search.last
      expect do
        Services::Searches::WithFiltersParametersSave.new(params_with_genre_and_writing_year, user).call 
      end.to change(Search, :count).by(0)
      expect(Search.first.id).to eq last_search.id
      expect(Search.first.genre_filter).to eq params_with_genre_and_writing_year['genre_filter'].to_i
      expect(Search.first.genre_int_id).to eq params_with_genre_and_writing_year['genre_int_id'].to_i
      expect(Search.first.writing_year_filter).to eq params_with_genre_and_writing_year['writing_year_filter'].to_i
      expect(Search.first.writing_year).to eq params_with_genre_and_writing_year['writing_year'].to_i
    end
  end
end
