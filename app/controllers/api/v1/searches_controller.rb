# frozen_string_literal: true

module Api
  module V1
    class SearchesController < ApplicationController
      skip_authorization_check
      before_action :doorkeeper_authorize!

      def full_text
        render json: Services::Searches::FullText.new(params[:query]).call
      end

      def with_filters
        current_user = nil
        api_call = true
        manage_filters
        render json: Services::Searches::WithFilters.new(params, current_user, api_call).call
      end

      private

      def manage_filters
        params['genre_filter'] = '1' if params['genre_int_id']
        params['start_date_filter'] = '1' if params['start_date_added(2i)'] && params['start_date_added(1i)']
        params['end_date_filter'] = '1' if params['end_date_added(2i)'] && params['end_date_added(1i)']
        params['rating_litres_average_filter'] = '1' if params['rating_litres_average']
        params['rating_litres_votes_count_filter'] = '1' if params['rating_litres_votes_count']
        params['rating_livelib_average_filter'] = '1' if params['rating_livelib_average']
        params['rating_livelib_votes_count_filter'] = '1' if params['rating_livelib_votes_count']
        params['writing_year_filter'] = '1' if params['writing_year']
        params['pages_count_filter'] = '1' if params['pages_count']
        params['comments_count_filter'] = '1' if params['comments_count']
      end
    end
  end
end
