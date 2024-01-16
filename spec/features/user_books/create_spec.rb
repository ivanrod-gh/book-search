require 'rails_helper'

feature 'User can save book information in books shelf', %q{
  In order to store specific book information for further use
  As an authentcated user
  I'd like to be able to save book information in my books shelf
} do
  given(:user) { create(:user) }
  given(:md_genre) { create(:genre, :modern_detectives) }
  given(:with_genre_book) do
    book = create(:book, name: 'with_genre')
    BookGenre.create(book: book, genre: md_genre)
  end
  # Необходимо, т.к. тестовая среда уничтожает данные Rating и замороженный хэш начинает указывать на пустое место
  given(:reinitialize_rating_instances_constant) do
    Rating::INSTANCES = {
      'litres' => (Rating.find_by(name: 'litres') || Rating.create(name: 'litres')),
      'livelib' => (Rating.find_by(name: 'livelib') || Rating.create(name: 'livelib'))
    }
  end

  describe 'Authenticated user tries to save book information', js: true do
    before { sign_in(user) }

    scenario 'on search with filters page' do
      reinitialize_rating_instances_constant
      with_genre_book
      visit(searches_show_variants_path)
      click_on 'Найти'
      
      wait_for_ajax
      within '.search-result-list' do
        find('.user-book-buttons-area a.button-add').click
      end

      wait_for_ajax
      within '.search-result-list' do
        expect(page).not_to have_link(nil, href: /user_books\/create/)
        expect(page).to have_link(nil, href: /user_books\/destroy/)
      end
    end
  end
end
