class SearchWithFiltersBookRatingSerializer < ActiveModel::Serializer
  attributes :rating_id, :average, :votes_count
end
