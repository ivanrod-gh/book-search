module Services
  class BookShelfDownload
    def send_to_mail(user)
      BookShelfDownloadMailer.books(user, books_list(user)).deliver_later
    end

    private

    def books_list(user)
      list = []
      user.books.includes(:authors).each do |book|
        options = { serializer: MailUserBookSerializer }
        serialized_resource = ActiveModelSerializers::SerializableResource.new(book, options)
        list << serialized_resource
      end
      list.as_json
    end
  end
end
