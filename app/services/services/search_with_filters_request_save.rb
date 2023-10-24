# frozen_string_literal: true

module Services
  class SearchWithFiltersRequestSave
    MAXIMUM_SEARCHES_COUNT = 10

    def initialize(params, current_user)
      @params = params.permit(
        :genre_filter, :start_date_filter, :end_date_filter, :rating_litres_average_filter,
        :rating_litres_votes_count_filter, :rating_livelib_average_filter, :rating_livelib_votes_count_filter,
        :writing_year_filter, :pages_count_filter, :comments_count_filter, :genre_int_id,
        'start_date_added(3i)'.to_sym, 'start_date_added(2i)'.to_sym, 'start_date_added(1i)'.to_sym,
        'end_date_added(3i)'.to_sym, 'end_date_added(2i)'.to_sym, 'end_date_added(1i)'.to_sym,
        :rating_litres_average, :rating_litres_votes_count, :rating_livelib_average, :rating_livelib_votes_count,
        :writing_year, :pages_count, :comments_count, :page
      )
      @current_user = current_user
    end

    def call
      perform_request_save
    end

    private

    def perform_request_save
      return unless @current_user && search_is_initial?

      search_params = calculate_search_params
      @current_user.searches.count < MAXIMUM_SEARCHES_COUNT ? save_search(search_params) : update_seach(search_params)
    end

    def calculate_search_params(search_params = {})
      @params.each do |pair|
        next if pair[0] =~ /authenticity_token|commit|controller|action/

        key = pair[0] =~ /(|)/ ? pair[0].gsub('(', '_').gsub(')', '') : pair[0]
        value = pair[1].to_i.positive? ? pair[1].to_i : nil
        search_params[key] = value
      end
      search_params.merge!(user: @current_user)
    end

    def search_is_initial?
      @params.each do |pair|
        return false if pair[0] =~ /^page$/
      end
      true
    end

    def save_search(search_params)
      Search.create!(search_params)
    end

    def update_seach(search_params)
      @current_user.searches.last.update(search_params.merge!(updated_at: Time.zone.now))
    end
  end
end
