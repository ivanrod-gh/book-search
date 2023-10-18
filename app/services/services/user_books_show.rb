# frozen_string_literal: true

module Services
  class UserBooksShow
    PER_PAGE = 25

    def initialize(params, current_user)
      @params = params
      @current_user = current_user
    end

    def call
      perform_books_show
    end

    private

    def perform_books_show
      @results = {}
      books_count = @current_user.books.count
      page = calculate_page(books_count)
      serialize_collection(page)
      inject_collection_data_in_results(books_count)
      inject_params_data_in_results(page)
      inject_user_data_in_results
      @results
    end

    def calculate_page(books_count)
      return 0 unless books_count.positive?

      page = @params[:page] ? to_zero_or_positive_i(@params[:page]) : 0
      maximum_page = (books_count.to_f / PER_PAGE).ceil - 1
      [page, maximum_page].min
    end

    def serialize_collection(page)
      @current_user.books.offset(page * PER_PAGE).limit(PER_PAGE).includes(:authors).includes(:litres_book_rating)
                   .includes(:livelib_book_rating).includes(:genres).each do |resource|
        options = { serializer: SearchWithFiltersBookSerializer }
        serialized_resource = ActiveModelSerializers::SerializableResource.new(resource, options)
        @results['books'] ||= []
        @results['books'] << serialized_resource
      end
    end

    def to_zero_or_positive_i(string)
      (number = string.to_i) >= 0 ? number : 0
    end

    def inject_collection_data_in_results(books_count)
      @results[:results] ||= {}
      @results[:results][:count] = books_count
      @results[:results][:per_page] = PER_PAGE
    end

    def inject_params_data_in_results(page)
      @results[:params] ||= {}
      @results[:params][:page] = page
    end

    def inject_user_data_in_results
      @results[:user] ||= {}
      @results[:user][:id] = @current_user.id if @current_user
    end
  end
end
