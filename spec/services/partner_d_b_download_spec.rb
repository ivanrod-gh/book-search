require 'rails_helper'

RSpec.describe Services::PartnerDBDownload do
  let(:service) { double('Services::PartnerDBDownload') }
  let(:task) { create(:worker_task, :download_simple) }

  it 'downloads partner db' do
    expect(Services::PartnerDBDownload).to receive(:new).with(task).and_return(service)
    expect(service).to receive(:call)
    Services::PartnerDBDownload.new(task).call
  end
end
