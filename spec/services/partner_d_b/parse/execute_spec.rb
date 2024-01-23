require 'rails_helper'

RSpec.describe Services::PartnerDB::Parse::Execute do
  let(:task_simple_db) { create(:worker_task, :parse_segments_simple) }
  let(:task_detailed_db) { create(:worker_task, :parse_segments_detailed) }
  let(:perform_simple_parsing_call) do
    `cp spec/files/partners_utf.yml #{JSON.parse(task_simple_db.data)['file_name']}`
    Services::PartnerDB::Parse::Execute.new(task_simple_db).call
  end
  let(:perform_detailed_parsing_call) do
    `cp spec/files/detailed_data.xml #{JSON.parse(task_detailed_db.data)['file_name']}`
    Services::PartnerDB::Parse::Execute.new(task_detailed_db).call
  end
  let(:service) { double('Service') }

  describe 'with partner db (simple) file' do
    it 'do nothing if no file exists' do
      Services::PartnerDB::Parse::Execute.new(task_simple_db).call
      expect(Book.count).to eq 0
      expect(Genre.count).to eq 0
      expect(BookGenre.count).to eq 0
    end

    it 'calls Services::PartnerDB::Parse::Genres' do
      expect(Services::PartnerDB::Parse::Genres).to receive(:new).and_return(service)
      expect(service).to receive(:call)
      perform_simple_parsing_call
    end

    it 'calls Services::PartnerDB::Parse::Simple' do
      expect(Services::PartnerDB::Parse::Simple).to receive(:new).and_return(service)
      expect(service).to receive(:call)
      perform_simple_parsing_call
    end
  end

  describe 'with partner db (detailed) file' do
    it 'do nothing if no file exists' do
      Services::PartnerDB::Parse::Execute.new(task_detailed_db).call
      expect(Author.count).to eq 0
      expect(BookAuthor.count).to eq 0
    end

    it 'do nothing if where was no previous simple db parsing' do
      perform_detailed_parsing_call
      expect(Author.count).to eq 0
      expect(BookAuthor.count).to eq 0
    end

    it 'calls Services::PartnerDB::Parse::Detailed' do
      expect(Services::PartnerDB::Parse::Detailed).to receive(:new).and_return(service)
      expect(service).to receive(:call)
      perform_detailed_parsing_call
    end
  end

  describe 'respond state to caller' do
    it 'return false when execution failed' do
      expect(Services::PartnerDB::Parse::Execute.new(task_simple_db).call).to eq false
    end

    it 'return true when execution successful' do
      `cp spec/files/partners_utf.yml #{JSON.parse(task_simple_db.data)['file_name']}`
      expect(Services::PartnerDB::Parse::Execute.new(task_simple_db).call).to eq true
    end
  end
end
