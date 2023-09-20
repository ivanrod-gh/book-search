# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres, source: :genre
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors, source: :author
  has_many :book_ratings, dependent: :destroy

  validates :int_id, presence: true, uniqueness: true
end
