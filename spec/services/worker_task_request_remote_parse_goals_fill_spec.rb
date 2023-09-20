require 'rails_helper'

RSpec.describe Services::WorkerTaskRequestRemoteParseGoalsFill do
  let(:create_genres) do
    RemoteParseGoal::GOAL_TEMPLATES.each { |goal| Genre.create!(int_id: goal['genre_int_id'], name: 'test_name')}
  end


  it 'do nothing if no required genres exists' do
    Services::WorkerTaskRequestRemoteParseGoalsFill.new.call
    expect(RemoteParseGoal.all.count).to eq 0
  end

  it 'add remote parse goals from templates if required genres exists' do
    create_genres
    Services::WorkerTaskRequestRemoteParseGoalsFill.new.call
    expect(RemoteParseGoal.all.count).to eq RemoteParseGoal::GOAL_TEMPLATES.size
  end

  describe 'respond state to caller' do
    it 'return false when execution failed' do
      expect(Services::WorkerTaskRequestRemoteParseGoalsFill.new.call).to eq false
    end

    it 'return true when execution successful' do
      create_genres
      expect(Services::WorkerTaskRequestRemoteParseGoalsFill.new.call).to eq true
    end
  end
end
