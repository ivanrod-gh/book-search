# frozen_string_literal: false

module Services
  module PartnerDB
    module Parse
      class Detailed
        def initialize(element)
          @element = element
        end

        def call
          parse_detailed_db_segment(@element)
        end

        private

        def parse_detailed_db_segment(art)
          return if not_text_type(art) || lack_of_critical_detailed_data(art)

          book = Book.find_by(int_id: art['int_id'])

          return if not_found_or_with_full_data_already?(book)

          book_data = gather_detailed_book_data(art)
          manage_book(book, book_data)
        end

        def not_text_type(art)
          art['type'] != '0'
        end

        def lack_of_critical_detailed_data(art)
          return true if art['int_id'].blank? || art['added'].blank? || art.at_css('book-title').blank?
        end

        def not_found_or_with_full_data_already?(book)
          return true if book.nil?

          book.name.present?
        end

        def gather_detailed_book_data(art)
          book_data = {}
          book_data = book_initial_data(art, book_data)
          book_data['authors'] = book_authors_data(art, book_data)
          book_data = delete_partial_authors(book_data)
          book_data['author_int_ids'] = book_author_int_ids_data(book_data) if book_data['authors']
          book_data
        end

        def book_initial_data(art, book_data)
          book_data['writing_year'] = writing_year(art)
          book_data['date'] = art['added'].to_date
          book_data['name'] = extract_data(art, 'book-title', 0)
          book_data['authors'] = []
          art.css('title-info author').each do |author|
            book_data['authors'] << { 'int_id' => author.css('id')[0].content }
          end
          book_data
        end

        def extract_data(doc, query, index)
          return '' unless doc.css(query)[index]

          doc.css(query)[index].content
        end

        def writing_year(art)
          year_data = extract_data(art, 'title-info date', 0)
          if year_data =~ /[ -._]/
            calculdate_year(year_data)
          else
            (year = year_data.to_i).positive? ? year : nil
          end
        end

        def calculdate_year(year_data)
          (year = year_data.split(/[ -._]/).map(&:to_i).max).positive? ? year : nil
        end

        def book_authors_data(art, book_data)
          art.css('authors author').each do |involved|
            book_data['authors'].each do |author|
              author.merge!(extract_author_data(involved)) if involved['id'] == author['int_id']
            end
          end
          book_data['authors']
        end

        def extract_author_data(involved, author = {})
          author['name'] = author_name(involved).join(' ')
          author['url'] = extract_data(involved, 'url', 0)
          author
        end

        def author_name(involved)
          name = []
          name << extract_data(involved, 'first-name', 0) unless extract_data(involved, 'first-name', 0).empty?
          name << extract_data(involved, 'middle-name', 0) unless extract_data(involved, 'middle-name', 0).empty?
          name << extract_data(involved, 'last-name', 0) unless extract_data(involved, 'last-name', 0).empty?
          name
        end

        def delete_partial_authors(book_data)
          book_data['authors'].each do |author|
            book_data['authors'].delete(author) if lack_of_critical_author_data(author)
          end
          book_data.delete('authors') if book_data['authors'].size.zero?
          book_data
        end

        def lack_of_critical_author_data(author)
          return true if author['int_id'].blank? || author['name'].blank? || author['url'].blank?
        end

        def book_author_int_ids_data(book_data)
          book_data['authors'].each do |author|
            int_id = author['int_id']
            book_data['author_int_ids'] ? book_data['author_int_ids'] << int_id : book_data['author_int_ids'] = [int_id]
          end
          book_data['author_int_ids']
        end

        def manage_book(book, book_data)
          update_book(book, book_data)
          return unless book_data['authors']

          manage_authors(book_data)
          manage_book_authors(book, book_data)
        end

        def update_book(book, book_data)
          book.update(writing_year: book_data['writing_year'], date: book_data['date'], name: book_data['name'])
        end

        def manage_authors(book_data)
          book_data['authors'].each do |author_data|
            author = Author.find_by(int_id: author_data['int_id'])
            author.nil? ? create_author(author_data) : update_author(author, author_data)
          end
        end

        def create_author(author_data)
          Author.create(
            int_id: author_data['int_id'],
            name: author_data['name'],
            url: author_data['url']
          )
        end

        def update_author(author, author_data)
          author.update(
            name: author_data['name'],
            url: author_data['url']
          )
        end

        def manage_book_authors(book, book_data)
          book_author_int_ids = Author.where(id: BookAuthor.where(book: book).select(:author_id)).pluck(:int_id)
          authors = Author.where(int_id: book_data['author_int_ids'] + book_author_int_ids)
          (book_author_int_ids - book_data['author_int_ids']).each do |author_int_id|
            BookAuthor.find_by(book: book, author: authors.find_by(int_id: author_int_id)).destroy
          end
          (book_data['author_int_ids'] - book_author_int_ids).each do |author_int_id|
            BookAuthor.create(book: book, author: authors.find_by(int_id: author_int_id))
          end
        end
      end
    end
  end
end
