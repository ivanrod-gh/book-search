require 'rails_helper'

feature 'User can watch his books shelf', %q{
  In order to watch previously stored books information
  As an authentcated user
  I'd like to be able to watch my books shelf
} do
  given(:user) { create(:user) }
  given(:md_genre) { create(:genre, :modern_detectives) }
  given(:with_genre_book) do
    book = create(:book, name: 'with_genre')
    BookGenre.create(book: book, genre: md_genre)
  end
  given(:first_added_book) { create(:book, :date_added_1987, name: 'first_added') }
  given(:last_added_book) { create(:book, :date_added_2123, name: 'last_added') }
  given(:first_added_user_book) { create(:user_book, user: user, book: first_added_book) }
  given(:last_added_user_book) { create(:user_book, user: user, book: last_added_book) }

  describe 'Authenticated user', js: true do
    before { sign_in(user) }

    scenario 'tries to watch his books shelf' do
      with_genre_book
      first_added_user_book
      last_added_user_book
      visit(searches_show_variants_path)
      click_on 'Книжная полка'

      wait_for_ajax
      within '.user-books-list' do
        expect(page).not_to have_content 'with_genre'
        expect(page).to have_content 'first_added'
        expect(page).to have_content 'last_added'
      end
    end
  end
end
