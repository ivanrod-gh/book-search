require 'rails_helper'

RSpec.describe Services::WorkerTasks::Execute do
  let(:task) { create(:worker_task, :unzip_simple) }

  it 'do not call specific service if no task for this service exists' do
    expect(Services::PartnerDB::Unzip).not_to receive(:new)
    expect{ Services::WorkerTasks::Execute.new.call }.to change(WorkerTask, :count).by(0)
  end

  it 'manage specific task, call specific service when task exists but do not delete uncomplited (failed) tasks' do
    expect(Services::PartnerDB::Unzip).to receive(:new).with(task).and_call_original
    expect{ Services::WorkerTasks::Execute.new.call }.to change(WorkerTask, :count).by(0)
  end

  it 'manage specific task, call specific service when task exists and delete successfully complited task' do
    `cp spec/files/partners_utf.yml.gz #{JSON.parse(task.data)['archive_name']}`
    expect(Services::PartnerDB::Unzip).to receive(:new).with(task).and_call_original
    expect{ Services::WorkerTasks::Execute.new.call }.to change(WorkerTask, :count).by(-1)
    File.delete(JSON.parse(task.data)['file_name'])
  end

  describe 'respond state to caller' do
    it 'return false when execution failed' do
      expect(Services::WorkerTasks::Execute.new.call).to eq false
    end

    it 'return true when execution successful' do
      `cp spec/files/partners_utf.yml.gz #{JSON.parse(task.data)['archive_name']}`
      expect(Services::WorkerTasks::Execute.new.call).to eq true
      File.delete(JSON.parse(task.data)['file_name'])
    end
  end
end
