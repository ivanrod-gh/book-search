# frozen_string_literal: true

class SearchesController < ApplicationController
  def show_variants
    authorize! :show_variants, Search
  end

  def full_text
    authorize! :full_text, Search
    render json: Services::Searches::FullText.new(params[:query]).call
  end

  def with_filters
    authorize! :with_filters, Search
    Services::Searches::WithFiltersParametersSave.new(params, current_user).call
    render json: Services::Searches::WithFilters.new(params, current_user).call
  end

  def retrieve_old_search_parameters
    authorize! :retrieve_old_search_parameters, Search
    render json: Services::Searches::WithFiltersParametersRetrieve.new(params, current_user).call
  end
end
