require "rails_helper"

RSpec.describe BookShelfDownloadMailer, type: :mailer do
  describe '#books' do
    let(:user) { create(:user) }
    let(:list) do
      [
        { book: { name: 'book1', authors: 'author_name1' }},
        { book: { name: 'book2', authors: 'author_name21 author_name22' }}
      ]
    end
    let(:mail) { BookShelfDownloadMailer.books(user, list) }

    it "renders the headers" do
      expect(mail.subject).to eq("BookSeach: список сохраненных книг и их авторов")
      expect(mail.to).to eq(["#{user.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match('book1')
      expect(mail.body.encoded).to match('book2')
      expect(mail.body.encoded).to match('author_name1')
      expect(mail.body.encoded).to match('author_name21')
      expect(mail.body.encoded).to match('author_name22')
    end
  end
end
