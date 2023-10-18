class SearchSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :genre_filter, :start_date_filter, :end_date_filter, :rating_litres_average_filter,
             :rating_litres_votes_count_filter, :rating_livelib_average_filter, :rating_livelib_votes_count_filter,
             :writing_year_filter, :pages_count_filter, :comments_count_filter, :genre_int_id, :start_date_added_3i,
             :start_date_added_2i, :start_date_added_1i, :end_date_added_3i, :end_date_added_2i, :end_date_added_1i,
             :rating_litres_average, :rating_litres_votes_count, :rating_livelib_average, :rating_livelib_votes_count,
             :writing_year, :pages_count, :comments_count

end
