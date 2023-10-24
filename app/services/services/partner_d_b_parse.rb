# frozen_string_literal: false

module Services
  class PartnerDBParse
    # Обработка 250*100=25.000 записей
    BOOKS_COUNT_FOR_ITERATION = 250
    ITERATIONS_COUNT = 100

    def initialize(task)
      @task_name = task['name']
      parsed_task_data = JSON.parse(task.data)
      @book_key = parsed_task_data['book_key']
      @file_name = parsed_task_data['file_name']
      @eol = parsed_task_data['end_of_line']
      @all_genre_int_ids = []
      @eol_counter = 0
      @output = ''
      @segment_index = 0
    end

    def call
      return false unless start_conditions_satisfied?

      File.open(@file_name, 'r', encoding: 'utf-8').each_line do |line|
        raw_parse(line)
        break if @segment_index == ITERATIONS_COUNT
      end
      manage_segment_parsing if @output.size.positive?
      delete_partner_db_file
      finish_conditions_satisfied?
    end

    private

    def start_conditions_satisfied?
      if File.exist?(@file_name)
        Rails.logger.info "Partner DB file (#{@file_name}) found, parsing started"
        true
      else
        Rails.logger.info "No partner DB file (#{@file_name}) found"
        false
      end
    end

    def raw_parse(line)
      @eol_counter += 1 if line.include?(@eol)
      if @eol_counter == BOOKS_COUNT_FOR_ITERATION
        parse_raw_data(line)
      else
        @output << line
      end
    end

    def parse_raw_data(line)
      splitted_line = line.split(@eol)
      @output << "#{splitted_line[0]}#{@eol}"
      manage_segment_parsing
      @eol_counter = 0
      @segment_index += 1
      Rails.logger.info "Segment N#{@segment_index} passed"
      @output = (splitted_line[1]).to_s
      # Ограничение на нагрузку процессора
      sleep(1)
    end

    def manage_segment_parsing
      parse_simple_db_genres_segment if @task_name == 'partner_db_parse_segments_simple' && @segment_index.zero?
      prepare_all_genre_int_ids
      parse_db_segment
    end

    def parse_simple_db_genres_segment
      all_genres = {}
      doc = Nokogiri::HTML(@output, nil, Encoding::UTF_8.to_s)
      doc.css('categories category').each do |category|
        all_genres[category['id']] = category.content.capitalize unless all_genres.key?(category['id'])
      end
      manage_genres(all_genres)
    end

    def manage_genres(all_genres)
      all_genres.each do |int_id, name|
        genre = Genre.find_by(int_id: int_id)
        genre.nil? ? Genre.create!(int_id: int_id, name: name) : genre.update!(name: name)
      end
    end

    def prepare_all_genre_int_ids
      @all_genre_int_ids = Genre.pluck(:int_id)
    end

    def parse_db_segment
      doc = Nokogiri::HTML(@output, nil, Encoding::UTF_8.to_s)
      doc.css(@book_key).each do |element|
        @book_key == 'offer' ? parse_simple_db_segment(element) : parse_detailed_db_segment(element)
      end
    end

    def parse_simple_db_segment(offer)
      return if not_book_type(offer) || lack_of_critical_simple_data(offer)

      book_data = gather_simple_book_data(offer)
      manage_book_genres(book_data, find_or_create_book(book_data))
    end

    def not_book_type(offer)
      offer['type'] != 'book'
    end

    def lack_of_critical_simple_data(offer)
      return true if offer['id'].blank? || offer.at_css('genres_list').nil? ||
                     offer.at_css('genres_list').content.empty?
    end

    def gather_simple_book_data(offer)
      book_data = {}
      book_data['int_id'] = offer['id']
      book_data['genre_int_ids'] = []
      book_data['genre_int_ids'] = extract_data(offer, 'genres_list', 0).split(',') & @all_genre_int_ids
      book_data
    end

    def extract_data(doc, query, index)
      return '' unless doc.css(query)[index]

      doc.css(query)[index].content
    end

    def find_or_create_book(book_data)
      book = Book.find_by(int_id: book_data['int_id'])
      book.nil? ? Book.create!(int_id: book_data['int_id']) : book
    end

    def manage_book_genres(book_data, book)
      book_genre_int_ids = Genre.where(id: BookGenre.where(book: book).select(:genre_id)).pluck(:int_id)
      genres = Genre.where(int_id: book_data['genre_int_ids'] + book_genre_int_ids)
      (book_genre_int_ids - book_data['genre_int_ids']).each do |genre_int_id|
        BookGenre.find_by(book: book, genre: genres.find_by(int_id: genre_int_id)).destroy
      end
      (book_data['genre_int_ids'] - book_genre_int_ids).each do |genre_int_id|
        BookGenre.create!(book: book, genre: genres.find_by(int_id: genre_int_id))
      end
    end

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
      book.update!(writing_year: book_data['writing_year'], date: book_data['date'], name: book_data['name'])
    end

    def manage_authors(book_data)
      book_data['authors'].each do |author_data|
        author = Author.find_by(int_id: author_data['int_id'])
        author.nil? ? create_author(author_data) : update_author(author, author_data)
      end
    end

    def create_author(author_data)
      Author.create!(
        int_id: author_data['int_id'],
        name: author_data['name'],
        url: author_data['url']
      )
    end

    def update_author(author, author_data)
      author.update!(
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
        BookAuthor.create!(book: book, author: authors.find_by(int_id: author_int_id))
      end
    end

    def delete_partner_db_file
      File.delete(@file_name)
    end

    def finish_conditions_satisfied?
      @book_key == 'offer' ? check_partner_db_simple_conditions : check_partner_db_detailed_conditions
    end

    def check_partner_db_simple_conditions
      if Genre.count.positive? && Book.count.positive? && !File.exist?(@file_name)
        finish_conditions_satisfied
      elsif Genre.count.zero? || Book.count.zero? || File.exist?(@file_name)
        finish_conditions_unsatisfied
      end
    end

    def check_partner_db_detailed_conditions
      if Author.count.positive? && !File.exist?(@file_name)
        finish_conditions_satisfied
      elsif Author.count.zero? || File.exist?(@file_name)
        finish_conditions_unsatisfied
      end
    end

    def finish_conditions_satisfied
      Rails.logger.info "Partner DB successfully parsed"
      true
    end

    def finish_conditions_unsatisfied
      Rails.logger.info "Partner DB parsing failed - no data gathered or partner db file exists"
      false
    end
  end
end
