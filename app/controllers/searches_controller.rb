# frozen_string_literal: true

class SearchesController < ApplicationController
  def index; end

  def full_text
    render json: Services::SearchFullText.new(params[:query]).call
  end

  def with_filters
    render json: Services::SearchWithFilters.new(params).call
  end
end
