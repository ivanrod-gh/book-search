require 'rails_helper'

RSpec.describe Services::RemotePageParse do
  let!(:book) { create(:book, :frontier) }
  let(:task) { create(:worker_task, :remote_parse) }
  let(:nokigiri_bad_downloaded_page) { Nokogiri::HTML(File.open('spec/files/page_bad.html')) }
  let(:nokigiri_good_downloaded_page) { Nokogiri::HTML(File.open('spec/files/page_good.html')) }
  # Необходимо, т.к. тестовая среда уничтожает данные Rating и замороженный хэш начинает указывать на пустое место
  let(:reinitialize_rating_instances_constant) do
    Rating::INSTANCES = {
      'litres' => (Rating.find_by(name: 'litres') || Rating.create(name: 'litres')),
      'livelib' => (Rating.find_by(name: 'livelib') || Rating.create(name: 'livelib'))
    }
  end

  describe 'work with bad HTML page (corrupted page)' do
    before do
      allow_any_instance_of(Services::RemotePageParse).to receive(:page).and_return(nokigiri_bad_downloaded_page)
      Services::RemotePageParse.new(task).call
    end

    it 'parse and save no book data' do
      expect(book.pages_count).to eq nil
      expect(book.comments_count).to eq nil
    end

    it 'create no book ratings' do
      expect(BookRating.all.count).to eq 0
    end

    it 'report \'empty_page\' execution status to worker service' do
      expect(Services::Worker.task_execution_status).to eq 'empty_page'
    end
  end

  describe 'parse data from good HTML page' do
    before do
      reinitialize_rating_instances_constant
      allow_any_instance_of(Services::RemotePageParse).to receive(:page).and_return(nokigiri_good_downloaded_page)
      Services::RemotePageParse.new(task).call
    end

    it 'save book data' do
      book.reload
      expect(book.pages_count).to eq 840
      expect(book.comments_count).to eq 8
    end

    it 'create book ratings for book' do
      expect(BookRating.first.rating_id).to eq Rating::INSTANCES['litres'].id
      expect(BookRating.first.average).to eq 4.2
      expect(BookRating.first.votes_count).to eq 40
      expect(BookRating.last.rating_id).to eq Rating::INSTANCES['livelib'].id
      expect(BookRating.last.average).to eq 4.3
      expect(BookRating.last.votes_count).to eq 350
    end
  end

  describe 'respond state to caller' do
    it 'return false when execution failed' do
      allow_any_instance_of(Services::RemotePageParse).to receive(:page).and_return(nokigiri_bad_downloaded_page)
      expect(Services::RemotePageParse.new(task).call).to eq false
    end

    it 'return true when execution successful' do
      reinitialize_rating_instances_constant
      allow_any_instance_of(Services::RemotePageParse).to receive(:page).and_return(nokigiri_good_downloaded_page)
      expect(Services::RemotePageParse.new(task).call).to eq true
    end
  end
end
