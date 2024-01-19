require 'rails_helper'

RSpec.describe Services::Searches::WithFiltersParametersRetrieve, type: :service do
  let(:empty_hash) { {} }
  let(:user) { create(:user) }
  let(:search) { create(:search, user: user) }

  context 'then called from authorized user' do
    context 'with no search requests' do
      it 'does not retrieve search request parameters then user has no search requests' do
        expect(Services::Searches::WithFiltersParametersRetrieve.new({}, user).call).to eq empty_hash
      end
    end

    context 'with search requests' do
      before { search }

      it 'does not retrieve search request parameters then found no search request with given id' do
        expect(
          Services::Searches::WithFiltersParametersRetrieve.new({ id: search.id + 10 }, user).call
        ).to eq empty_hash
      end

      it 'retrieve search request parameters' do
        expect(
          Services::Searches::WithFiltersParametersRetrieve.new({ id: search.id }, user).call
        ).to eq search
      end
    end
  end
end
