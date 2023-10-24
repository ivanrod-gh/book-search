class BookShelfDownloadMailer < ApplicationMailer
  def books(user, list)
    @list = list
    mail to: user.email, subject: 'BookSeach: список сохраненных книг и их авторов'
  end
end
