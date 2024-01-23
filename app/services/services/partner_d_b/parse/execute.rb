# frozen_string_literal: false

module Services
  module PartnerDB
    module Parse
      class Execute
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
          if @task_name == 'partner_db_parse_segments_simple' && @segment_index.zero?
            Services::PartnerDB::Parse::Genres.new(@output).call
            @all_genre_int_ids = Genre.pluck(:int_id)
          end
          parse_db_segment
        end

        def parse_db_segment
          doc = Nokogiri::HTML(@output, nil, Encoding::UTF_8.to_s)
          doc.css(@book_key).each do |element|
            if @book_key == 'offer'
              Services::PartnerDB::Parse::Simple.new(element, @all_genre_int_ids).call
            else
              Services::PartnerDB::Parse::Detailed.new(element).call
            end
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
  end
end
