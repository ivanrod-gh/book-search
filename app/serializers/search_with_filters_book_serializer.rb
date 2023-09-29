class SearchWithFiltersBookSerializer < ActiveModel::Serializer
  attributes :id, :int_id, :name, :date, :writing_year, :pages_count, :comments_count
  has_many :authors, serializer: SearchWithFiltersBookAuthorSerializer
  has_many :genres, serializer: SearchWithFiltersBookGenresSerializer
  has_one :litres_book_rating, serializer: SearchWithFiltersBookRatingSerializer
  has_one :livelib_book_rating, serializer: SearchWithFiltersBookRatingSerializer
end
