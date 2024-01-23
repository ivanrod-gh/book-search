require 'rails_helper'

RSpec.describe Services::PartnerDB::Parse::Detailed do
  describe 'perform detailed db element parsing after genres db parsing' do
    before do
      Services::PartnerDB::Parse::Genres.new(File.open('spec/files/partners_utf.yml').read).call
      Services::PartnerDB::Parse::Simple.new(
        Nokogiri::HTML(File.open('spec/files/partners_utf.yml').read, nil, Encoding::UTF_8.to_s).at_css('offer'),
        Genre.pluck(:int_id)
      ).call
      Services::PartnerDB::Parse::Detailed.new(
        Nokogiri::HTML(File.open('spec/files/detailed_data.xml').read, nil, Encoding::UTF_8.to_s).at_css('art')
      ).call
    end

    it 'parse data to local db' do
      expect(Author.count).to eq 3
      expect(BookAuthor.count).to eq 3
    end

    it 'add additional book data from parsing' do
      expect(Book.first.name).to eq 'Рубеж'
      expect(Book.first.date.to_date.to_s).to eq '2007-07-25'
      expect(Book.first.writing_year).to eq 1999
    end

    it 'add author data from parsing' do
      expect(Author.first.int_id).to eq 'e00dfc87-2a80-102a-9ae1-2dfe723fe7c7'
      expect(Author.first.name).to eq 'Марина и Сергей Дяченко'
      expect(Author.first.url).to eq 'marina-i-sergey-dyachenko/'
      expect(Author.second.int_id).to eq 'fa1edcf9-2a80-102a-9ae1-2dfe723fe7c7'
      expect(Author.second.name).to eq 'Генри Лайон Олди'
      expect(Author.second.url).to eq 'genri-layon-oldi/'
      expect(Author.last.int_id).to eq '34514c16-2a81-102a-9ae1-2dfe723fe7c7'
      expect(Author.last.name).to eq 'Андрей Валентинов'
      expect(Author.last.url).to eq 'andrey-valentinov/'
    end
  end
end
