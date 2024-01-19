# frozen_string_literal: true

module Services
  module Searches
    class WithFiltersParametersRetrieve
      def initialize(params, current_user)
        @params = params
        @current_user = current_user
      end

      def call
        perform_parameters_retrieve
      end

      private

      def perform_parameters_retrieve
        return {} unless user_has_old_searches

        (search = @current_user.searches.find_by(id: @params[:id])) ? search : {}
      end

      def user_has_old_searches
        return false unless @current_user.searches.count.positive?

        true
      end
    end
  end
end
