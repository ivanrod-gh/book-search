require 'rails_helper'

RSpec.describe Services::PartnerDBParse do
  let(:task_simple_db) { create(:worker_task, :parse_segments_simple) }
  let(:task_detailed_db) { create(:worker_task, :parse_segments_detailed) }
  let(:perform_simple_parsing_call) do
    `cp spec/files/partners_utf.yml #{JSON.parse(task_simple_db.data)['file_name']}`
    Services::PartnerDBParse.new(task_simple_db).call
  end
  let(:perform_detailed_parsing_call) do
    `cp spec/files/detailed_data.xml #{JSON.parse(task_detailed_db.data)['file_name']}`
    Services::PartnerDBParse.new(task_detailed_db).call
  end

  describe 'with partner db (simple) file' do
    it 'do nothing if no file exists' do
      Services::PartnerDBParse.new(task_simple_db).call
      expect(Book.count).to eq 0
      expect(Genre.count).to eq 0
      expect(BookGenre.count).to eq 0
    end

    it 'parse data from file to local db' do
      perform_simple_parsing_call
      expect(Book.count).to eq 1
      expect(Genre.count).to eq 2
      expect(BookGenre.count).to eq 2
    end

    it 'add specifing book data from parsing' do
      perform_simple_parsing_call
      expect(Book.first.int_id).to eq '121281'
    end

    it 'add specifing genre data from parsing' do
      perform_simple_parsing_call
      expect(Genre.first.int_id).to eq '5075'
      expect(Genre.first.name).to eq 'Героическая фантастика'
      expect(Genre.last.int_id).to eq '5226'
      expect(Genre.last.name).to eq 'Книги про волшебников'
    end
  end

  describe 'with partner db (detailed) file' do
    it 'do nothing if no file exists' do
      Services::PartnerDBParse.new(task_detailed_db).call
      expect(Author.count).to eq 0
      expect(BookAuthor.count).to eq 0
    end

    it 'do nothing if where was no previous simple db parsing' do
      perform_detailed_parsing_call
      expect(Author.count).to eq 0
      expect(BookAuthor.count).to eq 0
    end

    describe 'if where was previous simple db parsing' do
      let!(:perform_simple_and_detailed_parsing_calls) do
        perform_simple_parsing_call
        perform_detailed_parsing_call
      end

      it 'parse data from file to local db' do
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

  describe 'respond state to caller' do
    it 'return false when execution failed' do
      expect(Services::PartnerDBParse.new(task_simple_db).call).to eq false
    end

    it 'return true when execution successful' do
      `cp spec/files/partners_utf.yml #{JSON.parse(task_simple_db.data)['file_name']}`
      expect(Services::PartnerDBParse.new(task_simple_db).call).to eq true
    end
  end
end
