# frozen_string_literal: true

module Services
  class RemotePageParse
    def initialize(task)
      @int_id = JSON.parse(task.data)['int_id']
    end

    def call
      doc = page
      return false unless page_have_data?(doc)

      book_data = extract_book_data(doc)
      manage_book_update(book_data)
    end

    private

    def page
      Nokogiri::HTML(URI.open("http://www.litres.ru/pages/biblio_book/?art=#{@int_id}", read_timeout: 10))
    end

    def page_have_data?(doc)
      if doc.at_css('div.biblio_book_name.biblio-book__title-block h1').nil?
        Services::Worker.task_execution_status = 'empty_page'
        logger_and_respond('Parsing error: server responds with empty (partial data) page', false)
      else
        true
      end
    end

    def extract_book_data(doc, book_data = {})
      book_data['pages_count'] = integer_or_nil(extract_data(doc, 'div.biblio_book_info ul li.volume', 0))
      book_data['comments_count'] = integer_or_nil(extract_data(doc, 'div.recenses-count div.rating-text-wrapper', 0))
      book_data['litres_rating'] = float_or_nil(extract_data(doc, 'div.rating-number.bottomline-rating', 0))
      book_data['litres_votes_count'] = integer_or_nil(extract_data(doc, 'div.votes-count.bottomline-rating-count', 0))
      book_data['livelib_rating'] = float_or_nil(extract_data(doc, 'div.rating-number.bottomline-rating', 1))
      book_data['livelib_votes_count'] = integer_or_nil(extract_data(doc, 'div.votes-count.bottomline-rating-count', 1))
      book_data
    end

    def extract_data(doc, query, index)
      return '' unless doc.css(query)[index]

      doc.css(query)[index].content
    end

    def integer_or_nil(value)
      return nil unless value

      value = value.gsub(/[^\d]/, '').to_i
      value.positive? ? value : nil
    end

    def float_or_nil(value)
      return nil unless value

      value = value.gsub(',', '.').to_f
      value.positive? ? value : nil
    end

    def manage_book_update(book_data)
      book = Book.find_by(int_id: @int_id)
      update_book(book, book_data)
      manage_book_rating(book, book_data)
      logger_and_respond("Remote page for book with internal id '#{book.int_id}' successfully parsed")
    end

    def update_book(book, book_data)
      if book_data['pages_count'] && book_data['comments_count']
        book.update(pages_count: book_data['pages_count'], comments_count: book_data['comments_count'])
      elsif book_data['pages_count'] && !book_data['comments_count']
        book.update(pages_count: book_data['pages_count'])
      elsif !book_data['pages_count'] && book_data['comments_count']
        book.update(comments_count: book_data['comments_count'])
      end
    end

    def manage_book_rating(book, book_data)
      manage_rating_for(book, book_data, 'litres')
      manage_rating_for(book, book_data, 'livelib')
    end

    def manage_rating_for(book, book_data, source)
      book_rating = BookRating.find_by(book: book, rating: Rating::INSTANCES[source.to_s])
      if book_data["#{source}_rating"] && book_data["#{source}_votes_count"]
        rating_create_or_update(book, book_data, book_rating, source)
      elsif book_rating
        rating_destroy(book_rating)
      end
    end

    def rating_create_or_update(book, book_data, book_rating, source)
      if book_rating
        book_rating.update(average: book_data["#{source}_rating"], votes_count: book_data["#{source}_votes_count"])
      else
        BookRating.create(book: book, rating: Rating::INSTANCES[source.to_s], average: book_data["#{source}_rating"],
                           votes_count: book_data["#{source}_votes_count"])
      end
    end

    def rating_destroy(book_rating)
      book_rating.destroy
    end

    def logger_and_respond(message, state = true)
      Rails.logger.info message
      state
    end
  end
end
