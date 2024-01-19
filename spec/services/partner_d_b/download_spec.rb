require 'rails_helper'

RSpec.describe Services::PartnerDB::Download do
  let(:task_simple_db) { create(:worker_task, :download_simple) }
  let(:task_detailed_db) { create(:worker_task, :download_detailed) }
  let(:downloaded_simple_file) { File.open(JSON.parse(task_simple_db.data)['file_name'], 'w') }
  let(:downloaded_detailed_file) { File.open(JSON.parse(task_detailed_db.data)['file_name'], 'w') }

  describe 'with partner db (simple) file' do
    it 'service ensures that folder for simple partner db file exist' do
      allow_any_instance_of(Services::PartnerDB::Download).to receive(:download_file)
      Services::PartnerDB::Download.new(task_simple_db).call
      expect(Dir.exist?('shared/partner_db')).to eq true
    end

    it 'does nothing if file download is unavailable' do
      allow_any_instance_of(Services::PartnerDB::Download).to receive(:download_file)
      Services::PartnerDB::Download.new(task_simple_db).call
      expect(File.exist?(JSON.parse(task_simple_db.data)['file_name'])).to eq false
    end

    it 'downloads file if available' do
      allow_any_instance_of(Services::PartnerDB::Download).to receive(:download_file)
        .and_return(downloaded_simple_file)
      expect(File.exist?(JSON.parse(task_simple_db.data)['file_name'])).to eq true
      Services::PartnerDB::Download.new(task_simple_db).call
      File.delete(JSON.parse(task_simple_db.data)['file_name'])
    end
  end

  describe 'with partner db (detailed) file' do
    it 'service ensures that folder for detailed partner db file exist' do
      allow_any_instance_of(Services::PartnerDB::Download).to receive(:download_file)
      Services::PartnerDB::Download.new(task_detailed_db).call
      expect(Dir.exist?('shared/partner_db')).to eq true
    end

    it 'does nothing if file download is unavailable' do
      allow_any_instance_of(Services::PartnerDB::Download).to receive(:download_file)
      Services::PartnerDB::Download.new(task_detailed_db).call
      expect(File.exist?(JSON.parse(task_detailed_db.data)['file_name'])).to eq false
    end

    it 'downloads file if available' do
      allow_any_instance_of(Services::PartnerDB::Download).to receive(:download_file)
        .and_return(downloaded_detailed_file)
      expect(File.exist?(JSON.parse(task_detailed_db.data)['file_name'])).to eq true
      Services::PartnerDB::Download.new(task_detailed_db).call
      File.delete(JSON.parse(task_detailed_db.data)['file_name'])
    end
  end

  describe 'respond state to caller' do
    it 'return false when execution failed' do
      allow_any_instance_of(Services::PartnerDB::Download).to receive(:download_file)
      expect(Services::PartnerDB::Download.new(task_simple_db).call).to eq false
    end

    it 'return true when execution successful' do
      allow_any_instance_of(Services::PartnerDB::Download).to receive(:download_file)
        .and_return(downloaded_simple_file)
      expect(Services::PartnerDB::Download.new(task_simple_db).call).to eq true
      File.delete(JSON.parse(task_simple_db.data)['file_name'])
    end
  end
end
