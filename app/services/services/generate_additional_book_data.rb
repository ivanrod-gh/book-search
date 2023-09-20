# frozen_string_literal: true

module Services
  class GenerateAdditionalBookData
    BOOKS_COUNT_FOR_ITERATION = 250
    BOOKS_WITH_COMMENTS_PERCENT = 30
    BOOKS_WITH_LITRES_RATING_PERCENT = 60
    BOOKS_WITH_LIVELIB_RATING_PERCENT = 40
    BOOK_MINIMUM_PAGES_COUNT = 10
    BOOK_MAXIMUM_PAGES_COUNT = 950
    BOOK_MINIMUM_COMMENTS_COUNT_IF_COMMENTED = 1
    BOOK_MAXIMUM_COMMENTS_COUNT_IF_COMMENTED = 50
    BOOK_MINIMUM_AVERAGE_RATING_IF_RATED = 6.0
    BOOK_MAXIMUM_AVERAGE_RATING_IF_RATED = 9.9
    BOOK_MINIMUM_VOTES_COUNT_IF_RATED = 1
    BOOK_MAXIMUM_VOTES_COUNT_IF_RATED = 500

    def call
      return false unless start_conditions_satisfied?

      manage_book_data_generation
      finish_conditions_satisfied?
    end

    def start_conditions_satisfied?
      Book.count.positive?
    end

    def manage_book_data_generation
      Book.where("date >= '1970-01-01'").each_with_index do |book, index|
        # Ограничение на нагрузку процессора
        sleep(1.0) if end_of_iteration_reached?(index)
        manage_data_update(book)
        manage_rating(book)
      end
    end

    def end_of_iteration_reached?(index)
      (index % BOOKS_COUNT_FOR_ITERATION).zero?
    end

    def manage_data_update(book)
      rand(0..99) < BOOKS_WITH_COMMENTS_PERCENT ? pages_and_comments_count_data(book) : pages_count_data(book)
    end

    def pages_and_comments_count_data(book)
      book.update!(pages_count: pages_count, comments_count: comments_count)
    end

    def pages_count
      rand(BOOK_MINIMUM_PAGES_COUNT..BOOK_MAXIMUM_PAGES_COUNT)
    end

    def comments_count
      Math.exp(rand(degree_minimum_comments..degree_maximum_comments)).round(0)
    end

    def degree_minimum_comments
      Math.log(BOOK_MINIMUM_COMMENTS_COUNT_IF_COMMENTED)
    end

    def degree_maximum_comments
      Math.log(BOOK_MAXIMUM_COMMENTS_COUNT_IF_COMMENTED)
    end

    def pages_count_data(book)
      book.update!(pages_count: pages_count)
    end

    def manage_rating(book)
      book_rating(book, 'litres') if rand(0..99) < BOOKS_WITH_LITRES_RATING_PERCENT
      book_rating(book, 'livelib') if rand(0..99) < BOOKS_WITH_LIVELIB_RATING_PERCENT
    end

    def book_rating(book, source)
      BookRating.create!(book: book, rating: Rating::INSTANCES[source], average: average, votes_count: votes_count)
    end

    def average
      rand(BOOK_MINIMUM_AVERAGE_RATING_IF_RATED..BOOK_MAXIMUM_AVERAGE_RATING_IF_RATED).round(1)
    end

    def votes_count
      Math.exp(rand(degree_minimum_votes..degree_maximum_votes)).round(0)
    end

    def degree_minimum_votes
      Math.log(BOOK_MINIMUM_VOTES_COUNT_IF_RATED)
    end

    def degree_maximum_votes
      Math.log(BOOK_MAXIMUM_VOTES_COUNT_IF_RATED)
    end

    def finish_conditions_satisfied?
      Book.where("date >= '1970-01-01'").where("pages_count >= 0").count.positive?
    end
  end
end
