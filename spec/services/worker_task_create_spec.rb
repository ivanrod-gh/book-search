require 'rails_helper'

RSpec.describe Services::WorkerTaskCreate do
  it 'creates partner_db_download_simple task with data' do
    expect{ subject.partner_db_download('simple') }.to change(WorkerTask, :count).by(1)
    expect(WorkerTask.first.name).to eq attributes_for(:worker_task, :download_simple)[:name]
    expect(WorkerTask.first.data).to eq attributes_for(:worker_task, :download_simple)[:data]
  end

  it 'creates partner_db_download_detailed task with data' do
    expect{ subject.partner_db_download('detailed') }.to change(WorkerTask, :count).by(1)
    expect(WorkerTask.first.name).to eq attributes_for(:worker_task, :download_detailed)[:name]
    expect(WorkerTask.first.data).to eq attributes_for(:worker_task, :download_detailed)[:data]
  end
  
  it 'creates partner_db_unzip_simple task with data' do
    expect{ subject.partner_db_unzip('simple') }.to change(WorkerTask, :count).by(1)
    expect(WorkerTask.first.name).to eq attributes_for(:worker_task, :unzip_simple)[:name]
    expect(WorkerTask.first.data).to eq attributes_for(:worker_task, :unzip_simple)[:data]
  end
  
  it 'creates partner_db_unzip_detailed task with data' do
    expect{ subject.partner_db_unzip('detailed') }.to change(WorkerTask, :count).by(1)
    expect(WorkerTask.first.name).to eq attributes_for(:worker_task, :unzip_detailed)[:name]
    expect(WorkerTask.first.data).to eq attributes_for(:worker_task, :unzip_detailed)[:data]
  end
  
  it 'creates partner_db_parse_segments_simple task with data' do
    expect{ subject.partner_db_parse_segments('simple') }.to change(WorkerTask, :count).by(1)
    expect(WorkerTask.first.name).to eq attributes_for(:worker_task, :parse_segments_simple)[:name]
    expect(WorkerTask.first.data).to eq attributes_for(:worker_task, :parse_segments_simple)[:data]
  end
  
  it 'creates partner_db_parse_segments_detailed task with data' do
    expect{ subject.partner_db_parse_segments('detailed') }.to change(WorkerTask, :count).by(1)
    expect(WorkerTask.first.name).to eq attributes_for(:worker_task, :parse_segments_detailed)[:name]
    expect(WorkerTask.first.data).to eq attributes_for(:worker_task, :parse_segments_detailed)[:data]
  end
end
