require 'rails_helper'

RSpec.describe Services::PartnerDB::Parse::Genres do
  describe 'perform simple db element parsing' do
    before do
      Services::PartnerDB::Parse::Genres.new(File.open('spec/files/partners_utf.yml').read).call
    end

    it 'add specifing genre data from parsing such db file' do
      expect(Genre.first.int_id).to eq '5075'
      expect(Genre.first.name).to eq 'Героическая фантастика'
      expect(Genre.last.int_id).to eq '5226'
      expect(Genre.last.name).to eq 'Книги про волшебников'
    end
  end
end
