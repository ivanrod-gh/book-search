# frozen_string_literal: true

module Services
  module Searches
    class FullText
      MINIMUM_QUERY_LENGTH = 3
      MAXIMUM_QUERY_LENGTH = 50
      MAXIMUM_FULL_TEXT_BOOKS_SEARCH_RESULTS_COUNT = 25
      MAXIMUM_FULL_TEXT_AUTHORS_SEARCH_RESULTS_COUNT = 25

      def initialize(query)
        @query = query
      end

      def call
        perform_search_full_text
      end

      private

      def perform_search_full_text
        @results = {}
        return @results unless query_chars_acceptable? && query_length_in_range?

        perform_sphinx_calls
        check_maximum_result_count_reaching
        @results
      end

      def query_chars_acceptable?
        @query.to_s.each_char do |char|
          next unless char !~ /\w|[а-яА-Яё]|[-+ ]/

          @results['warning'] ||= {}
          @results['warning']['restricted_chars'] ||= ''
          @results['warning']['restricted_chars'] += char
        end
        !(@results.key?('warning') && @results['warning'].key?('restricted_chars'))
      end

      def query_length_in_range?
        if @query.length < MINIMUM_QUERY_LENGTH || @query.length > MAXIMUM_QUERY_LENGTH
          @results['warning'] ||= {}
          @results['warning']['query_length_data'] ||= {}
          @results['warning']['query_length_data']['minimum'] = MINIMUM_QUERY_LENGTH
          @results['warning']['query_length_data']['maximum'] = MAXIMUM_QUERY_LENGTH
          @results['warning']['query_length_data']['current'] = @query.length
        end
        !(@results.key?('warning') && @results['warning'].key?('query_length_data'))
      end

      def perform_sphinx_calls
        sphinx_search_books
        sphinx_search_authors
      end

      def sphinx_search_books
        ThinkingSphinx.search(
          @query, classes: [Book], order: :name, sql: { include: :authors }, star: true,
                  limit: MAXIMUM_FULL_TEXT_BOOKS_SEARCH_RESULTS_COUNT
        ).each do |resource|
          options = { serializer: SearchFullTextBookSerializer }
          serialized_resource = ActiveModelSerializers::SerializableResource.new(resource, options)
          @results[resource.class.to_s.pluralize.downcase] ||= []
          @results[resource.class.to_s.pluralize.downcase] << serialized_resource
        end
      end

      def sphinx_search_authors
        ThinkingSphinx.search(
          @query, classes: [Author], order: :name, sql: { include: :books }, star: true,
                  limit: MAXIMUM_FULL_TEXT_AUTHORS_SEARCH_RESULTS_COUNT
        ).each do |resource|
          options = { serializer: SearchFullTextAuthorSerializer }
          serialized_resource = ActiveModelSerializers::SerializableResource.new(resource, options)
          @results[resource.class.to_s.pluralize.downcase] ||= []
          @results[resource.class.to_s.pluralize.downcase] << serialized_resource
        end
      end

      def check_maximum_result_count_reaching
        if @results['books'] && @results['books'].size == MAXIMUM_FULL_TEXT_BOOKS_SEARCH_RESULTS_COUNT
          @results['warning'] ||= {}
          @results['warning']['maximum_results_count_data'] ||= {}
          @results['warning']['maximum_results_count_data']['books'] = MAXIMUM_FULL_TEXT_BOOKS_SEARCH_RESULTS_COUNT
        end
        return unless @results['authors'] && @results['authors'].size == MAXIMUM_FULL_TEXT_AUTHORS_SEARCH_RESULTS_COUNT

        @results['warning'] ||= {}
        @results['warning']['maximum_results_count_data'] ||= {}
        @results['warning']['maximum_results_count_data']['authors'] = MAXIMUM_FULL_TEXT_AUTHORS_SEARCH_RESULTS_COUNT
      end
    end
  end
end
