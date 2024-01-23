# frozen_string_literal: false

module Services
  module PartnerDB
    module Parse
      class Simple
        def initialize(element, all_genre_int_ids)
          @element = element
          @all_genre_int_ids = all_genre_int_ids
        end

        def call
          parse_simple_db_segment(@element, @all_genre_int_ids)
        end

        private

        def parse_simple_db_segment(offer, genre_int_ids)
          return if not_book_type(offer) || lack_of_critical_simple_data(offer)

          book_data = gather_simple_book_data(offer, genre_int_ids)
          manage_book_genres(book_data, find_or_create_book(book_data))
        end

        def not_book_type(offer)
          offer['type'] != 'book'
        end

        def lack_of_critical_simple_data(offer)
          return true if offer['id'].blank? || offer.at_css('genres_list').nil? ||
                         offer.at_css('genres_list').content.empty?
        end

        def gather_simple_book_data(offer, genre_int_ids)
          book_data = {}
          book_data['int_id'] = offer['id']
          book_data['genre_int_ids'] = []
          book_data['genre_int_ids'] = extract_data(offer, 'genres_list', 0).split(',') & genre_int_ids
          book_data
        end

        def extract_data(doc, query, index)
          return '' unless doc.css(query)[index]

          doc.css(query)[index].content
        end

        def find_or_create_book(book_data)
          book = Book.find_by(int_id: book_data['int_id'])
          book.nil? ? Book.create(int_id: book_data['int_id']) : book
        end

        def manage_book_genres(book_data, book)
          book_genre_int_ids = Genre.where(id: BookGenre.where(book: book).select(:genre_id)).pluck(:int_id)
          genres = Genre.where(int_id: book_data['genre_int_ids'] + book_genre_int_ids)
          (book_genre_int_ids - book_data['genre_int_ids']).each do |genre_int_id|
            BookGenre.find_by(book: book, genre: genres.find_by(int_id: genre_int_id)).destroy
          end
          (book_data['genre_int_ids'] - book_genre_int_ids).each do |genre_int_id|
            BookGenre.create(book: book, genre: genres.find_by(int_id: genre_int_id))
          end
        end
      end
    end
  end
end
