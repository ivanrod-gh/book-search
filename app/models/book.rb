# frozen_string_literal: true

class Book < ApplicationRecord
  class << self
    attr_accessor :dates_added_list

    def first_and_last_date_added
      form_dates_added_list if Book.dates_added_list.nil?
      Book.dates_added_list.nil? ? default_dates_added : Book.dates_added_list
    end

    private

    def form_dates_added_list
      return unless Book.where("date >= '1970-01-01'").count.positive?

      Book.dates_added_list = {
        start_date_added: Book.where("date >= '1970-01-01'").order(date: :asc).first.date.to_date,
        end_date_added: Book.where("date >= '1970-01-01'").order(date: :asc).last.date.to_date
      }
    end

    def default_dates_added
      {
        start_date_added: Date.new(2000),
        end_date_added: Date.new(2000)
      }
    end
  end

  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres, source: :genre
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors, source: :author
  has_many :book_ratings, dependent: :destroy
  has_many :user_books, dependent: :destroy
  has_one :litres_book_rating, -> { where(rating_id: Rating::INSTANCES['litres'].id) }, class_name: 'BookRating'
  has_one :livelib_book_rating, -> { where(rating_id: Rating::INSTANCES['livelib'].id) }, class_name: 'BookRating'

  validates :int_id, presence: true, uniqueness: true
end
