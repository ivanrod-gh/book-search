require 'rails_helper'

RSpec.describe SearchesController, type: :controller do
  describe 'POST #full_text' do
    let(:query) { 'some_query%' }
    let(:service) { double('Services::SearchFullText') }
    let(:respond) { double("{test: 'results'}") }

    it 'calls SearchFullText service and renders respond as JSON' do
      expect(Services::SearchFullText).to receive(:new).with(query).and_return(service)
      expect(service).to receive(:call).and_return(respond)
      post :full_text, params: { query: query }, format: :js
      expect(response.body).to eq respond.to_json
    end
  end

  describe 'POST #search_with_filters' do
    let(:parameter) { 'value' }
    let(:service) { double('Services::SearchWithFilters') }
    let(:controller_params) do
      subject.params = {
        "parameter"=>"value", "format"=>"js", "controller"=>"searches", "action"=>"with_filters"
      }
    end
    let(:respond) { double("{test: 'results'}") }

    it 'calls SearchWithFilters service and renders respond as JSON' do
      
      expect(Services::SearchWithFilters).to receive(:new).with(controller_params).and_return(service)
      expect(service).to receive(:call).and_return(respond)
      post :with_filters, params: { parameter: parameter }, format: :js
      expect(response.body).to eq respond.to_json
    end
  end
end
