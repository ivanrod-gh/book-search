require 'rails_helper'

feature 'User can remove all books information from books shelf', %q{
  In order to remove all previously stored books information
  As an authentcated user
  I'd like to be able to clean up my books shelf
} do
  given(:user) { create(:user) }
  given(:md_genre) { create(:genre, :modern_detectives) }
  given(:with_genre_book) do
    book = create(:book, name: 'with_genre')
    BookGenre.create!(book: book, genre: md_genre)
    book
  end
  given(:first_added_book) { create(:book, :date_added_1998, name: 'first_added') }
  given(:last_added_book) { create(:book, :date_added_2025, name: 'last_added') }
  given(:with_genre_user_book) { create(:user_book, user: user, book: with_genre_book) }
  given(:first_added_user_book) { create(:user_book, user: user, book: first_added_book) }
  given(:last_added_user_book) { create(:user_book, user: user, book: last_added_book) }
  # Необходимо, т.к. тестовая среда уничтожает данные Rating и замороженный хэш начинает указывать на пустое место
  given(:reinitialize_rating_instances_constant) do
    Rating::INSTANCES = {
      'litres' => (Rating.find_by(name: 'litres') || Rating.create!(name: 'litres')),
      'livelib' => (Rating.find_by(name: 'livelib') || Rating.create!(name: 'livelib'))
    }
  end

  describe 'Authenticated user tries to remove all books information', js: true do
    before do
      with_genre_user_book
      first_added_user_book
      last_added_user_book
      sign_in(user)
    end

    scenario 'on books shelf page' do
      reinitialize_rating_instances_constant
      visit(searches_index_path)
      click_on 'Книжная полка'
      
      wait_for_ajax
      click_link(href: '/user_books/destroy_all')
      accept_confirm

      wait_for_ajax
      within '.user-books-list' do
        expect(page).to have_content 'На книжной полке пока нет сохраненных книг'
      end
    end
  end
end

