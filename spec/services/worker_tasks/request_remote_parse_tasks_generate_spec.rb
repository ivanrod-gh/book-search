require 'rails_helper'

RSpec.describe Services::WorkerTasks::RequestRemoteParseTasksGenerate do
  let(:genre) { create(:genre, :science_fiction) }
  let(:book) { create(:book, genres: [genre]) }
  let(:book_with_date) { create(:book, date: Time.zone.now, genres: [genre]) }
  let(:remote_parse_goal) { create(:remote_parse_goal, genre: genre) }
  let(:remote_parse_goal_with_actual_date) { create(:remote_parse_goal, :with_actual_date, genre: genre) }

  it 'do nothing if no genre found' do
    Services::WorkerTasks::RequestRemoteParseTasksGenerate.new.call
    expect(WorkerTask.count).to eq 0
  end

  it 'do nothing if genre exist, but no book found' do
    genre
    Services::WorkerTasks::RequestRemoteParseTasksGenerate.new.call
    expect(WorkerTask.count).to eq 0
  end

  it 'do nothing if genre and book exist, but book doesnt have date record' do
    genre
    book
    Services::WorkerTasks::RequestRemoteParseTasksGenerate.new.call
    expect(WorkerTask.count).to eq 0
  end

  it 'do nothing if genre and proper book exist, but no remote parse goal found' do
    genre
    book_with_date
    Services::WorkerTasks::RequestRemoteParseTasksGenerate.new.call
    expect(WorkerTask.count).to eq 0
  end

  it 'do nothing if genre, proper book and remote parse goal exists, but goal date has not arrived yet' do
    genre
    book_with_date
    remote_parse_goal
    Services::WorkerTasks::RequestRemoteParseTasksGenerate.new.call
    expect(WorkerTask.count).to eq 0
  end

  it 'create worker task (remote page parse) for proper book, genre and goal' do
    genre
    book_with_date
    remote_parse_goal_with_actual_date
    Services::WorkerTasks::RequestRemoteParseTasksGenerate.new.call
    expect(WorkerTask.count).to eq 1
    expect(WorkerTask.first.name).to eq 'remote_page_parse'
    expect(JSON.parse(WorkerTask.first.data)['int_id']).to eq book_with_date.int_id
  end

  describe 'respond state to caller' do
    it 'return false when execution failed' do
      expect(Services::WorkerTasks::RequestRemoteParseTasksGenerate.new.call).to eq false
    end

    it 'return true when execution successful' do
      genre
      book_with_date
      remote_parse_goal_with_actual_date
      expect(Services::WorkerTasks::RequestRemoteParseTasksGenerate.new.call).to eq true
    end
  end
end
