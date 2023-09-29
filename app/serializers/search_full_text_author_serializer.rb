class SearchFullTextAuthorSerializer < ActiveModel::Serializer
  attributes :id, :int_id, :name, :url

  has_many :books do
    object.books.to_a.count
  end
end
