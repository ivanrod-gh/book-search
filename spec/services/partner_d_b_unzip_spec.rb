require 'rails_helper'

RSpec.describe Services::PartnerDBUnzip do
  let(:task_simple_db) { create(:worker_task, :unzip_simple) }
  let(:task_detailed_db) { create(:worker_task, :unzip_detailed) }

  describe 'with partner db (simple) archive' do
    it 'do nothing if no archive exists' do
      Services::PartnerDBUnzip.new(task_simple_db).call
      expect(File.exist?(JSON.parse(task_simple_db.data)['file_name'])).to eq false
    end

    it 'unzips downloaded archive' do
      `cp spec/files/partners_utf.yml.gz #{JSON.parse(task_simple_db.data)['archive_name']}`
      Services::PartnerDBUnzip.new(task_simple_db).call
      expect(File.exist?(JSON.parse(task_simple_db.data)['file_name'])).to eq true
      File.delete(JSON.parse(task_simple_db.data)['file_name'])
    end
  end

  describe 'with partner db (detailed) archive' do
    it 'do nothing if no archive exists' do
      Services::PartnerDBUnzip.new(task_detailed_db).call
      expect(File.exist?(JSON.parse(task_detailed_db.data)['file_name'])).to eq false
    end

    it 'unzips downloaded archive' do
      `cp spec/files/detailed_data.xml.gz #{JSON.parse(task_detailed_db.data)['archive_name']}`
      Services::PartnerDBUnzip.new(task_detailed_db).call
      expect(File.exist?(JSON.parse(task_detailed_db.data)['file_name'])).to eq true
      File.delete(JSON.parse(task_detailed_db.data)['file_name'])
    end
  end
end
