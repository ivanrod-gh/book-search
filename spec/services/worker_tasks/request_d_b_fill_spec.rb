require 'rails_helper'

RSpec.describe Services::WorkerTasks::RequestDBFill do
  it 'add initial db tasks to worker tasks table' do
    Services::WorkerTasks::RequestDBFill.new.call
    expect(WorkerTask.all.count).to eq Services::WorkerTasks::RequestDBFill::FILL_APP_D_B_TASKS.size
  end

  describe 'respond state to caller' do
    it 'return false when execution failed' do
      allow_any_instance_of(Services::WorkerTasks::RequestDBFill).to receive(:check_tasks).and_return(false)
      expect(Services::WorkerTasks::RequestDBFill.new.call).to eq false
    end

    it 'return true when execution successful' do
      expect(Services::WorkerTasks::RequestDBFill.new.call).to eq true
    end
  end
end
