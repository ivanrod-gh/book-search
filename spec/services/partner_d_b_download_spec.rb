require 'rails_helper'

RSpec.describe Services::PartnerDBDownload do
  let(:task_simple_db) { create(:worker_task, :download_simple) }
  let(:task_detailed_db) { create(:worker_task, :download_detailed) }
  let(:downloaded_simple_file) { File.open(JSON.parse(task_simple_db.data)['file_name'], 'w') }
  let(:downloaded_detailed_file) { File.open(JSON.parse(task_detailed_db.data)['file_name'], 'w') }

  describe 'with partner db (simple) file' do
    it 'downloads file if available' do
      allow_any_instance_of(Services::PartnerDBDownload).to receive(:download_file).and_return(downloaded_simple_file)
      expect(File.exist?(JSON.parse(task_simple_db.data)['file_name'])).to eq true
      Services::PartnerDBDownload.new(task_simple_db).call
      File.delete(JSON.parse(task_simple_db.data)['file_name'])
    end

    it 'does nothing if file download is unavailable' do
      allow_any_instance_of(Services::PartnerDBDownload).to receive(:download_file)
      expect(File.exist?(JSON.parse(task_simple_db.data)['file_name'])).to eq false
    end
  end

  describe 'with partner db (detailed) file' do
    it 'downloads file if available' do
      allow_any_instance_of(Services::PartnerDBDownload).to receive(:download_file).and_return(downloaded_detailed_file)
      expect(File.exist?(JSON.parse(task_detailed_db.data)['file_name'])).to eq true
      Services::PartnerDBDownload.new(task_detailed_db).call
      File.delete(JSON.parse(task_detailed_db.data)['file_name'])
    end

    it 'does nothing if file download is unavailable' do
      allow_any_instance_of(Services::PartnerDBDownload).to receive(:download_file)
      expect(File.exist?(JSON.parse(task_detailed_db.data)['file_name'])).to eq false
    end
  end
end
