# frozen_string_literal: true

module Services
  module Searches
    class WithFilters
      PER_PAGE = 25

      def initialize(params, current_user = nil)
        @params = params
        @current_user = current_user
      end

      def call
        perform_search_with_filters
      end

      private

      def perform_search_with_filters
        @results = {}
        @search_parameters = {}
        return @results unless genre_exist? && dates_acceptable?

        collection = collect_books_with_filters
        inject_in_results(collection)
        @params[:page].blank? ? inject_params_data_in_results : inject_params_data_in_results('page_only')
        serialize_collection(collection)
        @results
      end

      def genre_exist?
        return true unless @params[:genre_filter] == '1'

        genre = Genre.find_by(int_id: @params[:genre_int_id])
        if genre.present?
          @search_parameters['genre_id'] = genre.id
        else
          @results['warning'] ||= {}
          @results['warning']['genre'] = 'does_not_exist'
          false
        end
      end

      def dates_acceptable?
        return false unless start_date_added_acceptable?

        end_date_added_acceptable?
      end

      def start_date_added_acceptable?
        return true unless @params[:start_date_filter] == '1'

        @search_parameters['start_date_added'] = Date.new(
          @params['start_date_added(1i)'].to_i, @params['start_date_added(2i)'].to_i, 1
        ).to_s
      rescue Date::Error
        @results['warning'] ||= {}
        @results['warning']['date_added_data'] ||= {}
        @results['warning']['date_added_data']['start'] = 'invalid'
        false
      end

      def end_date_added_acceptable?
        return true unless @params[:end_date_filter] == '1'

        @search_parameters['end_date_added'] = Date.new(
          @params['end_date_added(1i)'].to_i, @params['end_date_added(2i)'].to_i, -1
        ).to_s
      rescue Date::Error
        @results['warning'] ||= {}
        @results['warning']['date_added_data'] ||= {}
        @results['warning']['date_added_data']['end'] = 'invalid'
        false
      end

      def collect_books_with_filters
        collection = Book.all.order("books.date DESC, books.id DESC").where('length(books.name) > 0')
        collection = with_genre_and_date_added(collection)
        collection = with_ratings_writing_year_pages_and_comments_count(collection)
        collection.includes(:authors).includes(:litres_book_rating).includes(:livelib_book_rating)
                  .includes(:genres)
      end

      def with_genre_and_date_added(collection)
        collection = with_genre(collection) if @search_parameters.key?('genre_id')
        collection = with_start_date_added(collection) if @search_parameters.key?('start_date_added')
        collection = with_end_date_added(collection) if @search_parameters.key?('end_date_added')
        collection
      end

      def with_ratings_writing_year_pages_and_comments_count(collection)
        collection = with_litres_average_rating(collection) if @params[:rating_litres_average_filter] == '1'
        collection = with_litres_votes_count(collection) if @params[:rating_litres_votes_count_filter] == '1'
        collection = with_livelib_average_rating(collection) if @params[:rating_livelib_average_filter] == '1'
        collection = with_livelib_votes_count(collection) if @params[:rating_livelib_votes_count_filter] == '1'
        collection = with_writing_year(collection) if @params[:writing_year_filter] == '1'
        collection = with_pages_count(collection) if @params[:pages_count_filter] == '1'
        collection = with_comments_count(collection) if @params[:comments_count_filter] == '1'
        collection
      end

      def with_genre(collection)
        collection.joins(:genres).where(genres: { id: @search_parameters['genre_id'] })
      end

      def with_start_date_added(collection)
        collection.where('date >= ?', @search_parameters['start_date_added'])
      end

      def with_end_date_added(collection)
        collection.where('date <= ?', @search_parameters['end_date_added'])
      end

      def with_writing_year(collection)
        collection.where('writing_year >= ?', @params[:writing_year].to_i.to_s)
      end

      def with_litres_average_rating(collection)
        collection.joins(:litres_book_rating)
                  .where(litres_book_rating: { average: [@params[:rating_litres_average].to_f..] })
      end

      def with_litres_votes_count(collection)
        collection.joins(:litres_book_rating)
                  .where(litres_book_rating: { votes_count: [@params[:rating_litres_votes_count].to_f..] })
      end

      def with_livelib_average_rating(collection)
        collection.joins(:livelib_book_rating)
                  .where(livelib_book_rating: { average: [@params[:rating_livelib_average].to_f..] })
      end

      def with_livelib_votes_count(collection)
        collection.joins(:livelib_book_rating)
                  .where(livelib_book_rating: { votes_count: [@params[:rating_livelib_votes_count].to_f..] })
      end

      def with_pages_count(collection)
        collection.where('pages_count >= ?', @params[:pages_count].to_i)
      end

      def with_comments_count(collection)
        collection.where('comments_count >= ?', @params[:comments_count].to_i)
      end

      def inject_in_results(collection)
        inject_collection_data_in_results(collection) if @params[:page].blank?
        inject_user_data_in_results
      end

      def inject_collection_data_in_results(collection)
        @results[:results] ||= {}
        @results[:results][:count] = collection.count
        @results[:results][:per_page] = PER_PAGE
      end

      def inject_user_data_in_results
        @results[:user] ||= {}
        return unless @current_user

        @results[:user][:id] = @current_user.id
        @results[:user][:book_ids] = @current_user.books.ids
        inject_searches_updated_at_data if @current_user.searches.count.positive?
      end

      def inject_searches_updated_at_data
        @results[:user][:searches_updated_at_and_id] ||= []
        @results[:user][:searches_updated_at_and_id] = user_searches(@current_user.searches)
      end

      def user_searches(relation, searches = [])
        relation.each do |search|
          searches.push({ id: search.id, updated_at: search.updated_at.to_s })
        end
        searches
      end

      def serialize_collection(collection)
        page = @params[:page] ? to_zero_or_positive_i(@params[:page]) : 0
        collection.offset(page * PER_PAGE).limit(PER_PAGE).each do |resource|
          options = { serializer: SearchWithFiltersBookSerializer }
          serialized_resource = ActiveModelSerializers::SerializableResource.new(resource, options)
          @results['books'] ||= []
          @results['books'] << serialized_resource
        end
      end

      def to_zero_or_positive_i(string)
        (number = string.to_i) >= 0 ? number : 0
      end

      def inject_params_data_in_results(option = 'all')
        @results[:params] ||= {}
        params_hash = {}
        @params.each do |pair|
          next if pair[0] =~ /authenticity_token|commit|controller|action/

          next if option == 'page_only' && pair[0] !~ /^page$/

          params_hash[pair[0]] = pair[1]
        end
        @results[:params] = params_hash
      end
    end
  end
end
