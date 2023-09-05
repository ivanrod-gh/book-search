require 'rails_helper'

RSpec.describe Services::WorkerTaskExecute do
  let(:service) { double('Services::PartnerDBDownload') }
  let(:task) { create(:worker_task, :download_simple) }

  it 'do not call partner_db services if no task exists' do
    expect(Services::PartnerDBDownload).not_to receive(:new)
    expect(Services::PartnerDBUnzip).not_to receive(:new)
    expect(Services::PartnerDBParse).not_to receive(:new)
    expect { subject.call }.to change(WorkerTask, :count).by(0)
  end

  it 'manage specific task and call specific partner_db service when task is present' do
    expect(Services::PartnerDBDownload).to receive(:new).with(task).and_return(service)
    expect(service).to receive(:call)
    subject.call
  end
end
