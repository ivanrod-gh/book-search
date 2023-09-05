class Genre < ApplicationRecord
  has_many :book_genres, dependent: :destroy
  has_many :books, through: :book_genres, source: :book

  validates :int_id, presence: true, uniqueness: true
  validates :name, presence: true
end
