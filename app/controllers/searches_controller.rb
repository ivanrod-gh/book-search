# frozen_string_literal: true

class SearchesController < ApplicationController
  def index
    authorize! :index, Search
  end

  def full_text
    authorize! :full_text, Search
    render json: Services::SearchFullText.new(params[:query]).call
  end

  def with_filters
    authorize! :with_filters, Search
    Services::SearchWithFiltersRequestSave.new(params, current_user).call
    render json: Services::SearchWithFilters.new(params, current_user).call
  end

  def retrieve_old_search
    authorize! :retrieve_old_search, Search
    render json: Services::SearchWithFiltersRequestRetrieve.new(params, current_user).call
  end
end
