class SearchFullTextBookSerializer < ActiveModel::Serializer
  attributes :id, :int_id, :name, :writing_year
  has_many :authors, serializer: SearchFullTextBookAuthorSerializer
end
