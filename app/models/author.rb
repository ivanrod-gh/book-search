# frozen_string_literal: true

class Author < ApplicationRecord
  has_many :book_authors, dependent: :destroy
  has_many :books, through: :book_authors, source: :book

  validates :int_id, presence: true, uniqueness: true
  validates :name, presence: true
end
