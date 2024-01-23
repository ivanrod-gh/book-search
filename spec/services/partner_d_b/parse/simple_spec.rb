require 'rails_helper'

RSpec.describe Services::PartnerDB::Parse::Simple do
  describe 'perform simple db element parsing' do
    before do
      Services::PartnerDB::Parse::Genres.new(File.open('spec/files/partners_utf.yml').read).call
      Services::PartnerDB::Parse::Simple.new(
        Nokogiri::HTML(File.open('spec/files/partners_utf.yml').read, nil, Encoding::UTF_8.to_s).at_css('offer'),
        Genre.pluck(:int_id)
      ).call
    end

    it 'parse book data to local db' do
      expect(Book.count).to eq 1
      expect(Genre.count).to eq 2
      expect(BookGenre.count).to eq 2
    end

    it 'add specifing book data from parsing' do
      expect(Book.first.int_id).to eq '121281'
    end
  end
end
