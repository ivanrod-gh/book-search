# frozen_string_literal: false

module Services
  module PartnerDB
    module Parse
      class Genres
        def initialize(segment)
          @segment = segment
        end

        def call
          parse_simple_db_genres_segment(@segment)
        end

        private

        def parse_simple_db_genres_segment(segment)
          all_genres = {}
          doc = Nokogiri::HTML(segment, nil, Encoding::UTF_8.to_s)
          doc.css('categories category').each do |category|
            all_genres[category['id']] = category.content.capitalize unless all_genres.key?(category['id'])
          end
          manage_genres(all_genres)
        end

        def manage_genres(all_genres)
          all_genres.each do |int_id, name|
            genre = Genre.find_by(int_id: int_id)
            genre.nil? ? Genre.create(int_id: int_id, name: name) : genre.update(name: name)
          end
        end
      end
    end
  end
end
