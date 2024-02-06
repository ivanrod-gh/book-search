# frozen_string_literal: true

module Api
  module V1
    class SearchesController < ApplicationController
      skip_authorization_check
      before_action :doorkeeper_authorize!

      def full_text
        render json: Services::Searches::FullText.new(params[:query]).call
      end

      private

      def current_resource_user
        @current_resource_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end
