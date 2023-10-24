class BookShelfDownloadJob < ApplicationJob
  queue_as :default

  def perform(user)
    Services::BookShelfDownload.new.send_to_mail(user)
  end
end
