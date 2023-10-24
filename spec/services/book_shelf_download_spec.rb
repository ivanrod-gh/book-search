require 'rails_helper'

RSpec.describe Services::BookShelfDownload do
  let(:user) { create(:user) }
  let(:mailer) { double('BookShelfDownloadMailer') }

  it 'calls BookShelfDownloadMailer#books with user-caller' do
    expect(BookShelfDownloadMailer).to receive(:books).with(user, []).and_return(mailer)
    expect(mailer).to receive(:deliver_later)
    subject.send_to_mail(user)
  end
end
