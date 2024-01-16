require 'rails_helper'

feature 'User can remove book information from books shelf', %q{
  In order to remove previously stored specific book information
  As an authentcated user
  I'd like to be able to remove book information from my books shelf
} do
  given(:user) { create(:user) }
  given(:md_genre) { create(:genre, :modern_detectives) }
  given(:with_genre_book) do
    book = create(:book, name: 'with_genre')
    BookGenre.create(book: book, genre: md_genre)
    book
  end
  given(:with_genre_user_book) { create(:user_book, user: user, book: with_genre_book) }
  # Необходимо, т.к. тестовая среда уничтожает данные Rating и замороженный хэш начинает указывать на пустое место
  given(:reinitialize_rating_instances_constant) do
    Rating::INSTANCES = {
      'litres' => (Rating.find_by(name: 'litres') || Rating.create(name: 'litres')),
      'livelib' => (Rating.find_by(name: 'livelib') || Rating.create(name: 'livelib'))
    }
  end

  describe 'Authenticated user tries to remove book information', js: true do
    before do
      with_genre_user_book
      sign_in(user)
    end

    scenario 'on search with filters page' do
      reinitialize_rating_instances_constant
      visit(searches_show_variants_path)
      click_on 'Найти'
      
      wait_for_ajax
      within '.search-result-list' do
        find('.user-book-buttons-area a.button-remove').click
      end

      wait_for_ajax
      within '.search-result-list' do
        expect(page).to have_link(nil, href: /user_books\/create/)
        expect(page).not_to have_link(nil, href: /user_books\/destroy/)
      end
    end

    scenario 'on books shelf page' do
      reinitialize_rating_instances_constant
      visit(searches_show_variants_path)
      click_on 'Книжная полка'
      
      wait_for_ajax
      within '.user-books-list' do
        find('.user-book-button-area a.button-remove').click
      end

      wait_for_ajax
      within '.user-books-list' do
        expect(page).to have_content 'На книжной полке пока нет сохраненных книг'
      end
    end
  end
end

