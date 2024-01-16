require 'rails_helper'

RSpec.describe SearchesController, type: :controller do
  let(:user) { create(:user) }

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
      ActionController::Parameters.new(
        "parameter"=>"value",
        "format"=>"js",
        "controller"=>"searches",
        "action"=>"with_filters"
      )
    end
    let(:respond) { double("{test: 'results'}") }

    describe 'then called from unauthorized user' do
      it 'calls SearchWithFiltersRequestSave with current_user = nil' do
        allow(service).to receive(:call)
        expect(Services::SearchWithFiltersRequestSave).to receive(:new).with(controller_params, nil)
                                                                       .and_return(service)
        post :with_filters, params: { parameter: parameter }, format: :js
      end

      it 'calls SearchWithFilters with current_user = nil' do
        allow(service).to receive(:call)
        expect(Services::SearchWithFilters).to receive(:new).with(controller_params, nil).and_return(service)
        post :with_filters, params: { parameter: parameter }, format: :js
      end

      it 'calls SearchWithFilters service and renders respond as JSON' do
        expect(Services::SearchWithFilters).to receive(:new).with(controller_params, nil).and_return(service)
        expect(service).to receive(:call).and_return(respond)
        post :with_filters, params: { parameter: parameter }, format: :js
        expect(response.body).to eq respond.to_json
      end
    end

    describe 'then called from authorized user' do
      before { login(user) }

      it 'calls SearchWithFiltersRequestSave current_user = user-caller' do
        allow(service).to receive(:call)
        expect(Services::SearchWithFiltersRequestSave).to receive(:new).with(controller_params, user)
                                                                       .and_return(service)
        post :with_filters, params: { parameter: parameter }, format: :js
      end

      it 'calls SearchWithFilters with current_user = user-caller' do
        allow(service).to receive(:call)
        expect(Services::SearchWithFilters).to receive(:new).with(controller_params, user).and_return(service)
        post :with_filters, params: { parameter: parameter }, format: :js
      end

      it 'calls SearchWithFilters service with current_user and renders respond as JSON' do
        allow(service).to receive(:call)
        expect(Services::SearchWithFilters).to receive(:new).with(controller_params, user).and_return(service)
        expect(service).to receive(:call).and_return(respond)
        post :with_filters, params: { parameter: parameter }, format: :js
        expect(response.body).to eq respond.to_json
      end
    end
  end

  describe 'POST #retrieve_old_search_parameters' do
    let(:parameter) { 'value' }
    let(:service) { double('Services::SearchWithFiltersRequestRetrieve') }
    let(:controller_params) do
      ActionController::Parameters.new(
        "parameter"=>"value",
        "format"=>"js",
        "controller"=>"searches",
        "action"=>"retrieve_old_search_parameters"
      )
    end

    describe 'then called from authorized user' do
      before { login(user) }

      it 'calls SearchWithFiltersRequestRetrieve with current_user = user-caller' do
        allow(service).to receive(:call)
        expect(Services::SearchWithFiltersRequestRetrieve).to receive(:new).with(controller_params, user)
                                                                           .and_return(service)
        post :retrieve_old_search_parameters, params: { parameter: parameter }, format: :js
      end
    end
  end
end

