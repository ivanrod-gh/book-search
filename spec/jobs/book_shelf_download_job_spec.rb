require 'rails_helper'

RSpec.describe BookShelfDownloadJob, type: :job do
  let(:user) { create(:user) }
  let(:service) { double('Services::BookShelfDownload') }

  it 'calls BookShelfDownloadJob#send_to_mail with user-caller' do
    expect(Services::BookShelfDownload).to receive(:new).and_return(service)
    expect(service).to receive(:send_to_mail).with(user)
    BookShelfDownloadJob.perform_now(user)
  end
end
