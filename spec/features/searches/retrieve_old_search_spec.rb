require 'rails_helper'

feature 'User can use old searches as new seach parameters', %q{
  In order to easily find a needed books by specific criteria
  As an authenticated user
  I'd like to be able to use my own old search requests as new seach parameters
} do
  given(:md_genre) { create(:genre, :modern_detectives) }
  given(:with_genre_book) do
    book = create(:book, name: 'with_genre')
    BookGenre.create!(book: book, genre: md_genre)
  end
  given(:first_added_book) { create(:book, :date_added_1998, name: 'first_added') }
  given(:last_added_book) { create(:book, :date_added_2025, name: 'last_added') }
  given(:with_litres_rating_book) do
    book = create(:book, name: 'litres_rating')
    BookRating.create!(book_id: book.id, rating: Rating::INSTANCES['litres'], average: 8, votes_count: 10)
  end
  given(:with_livelib_rating_book) do
    book = create(:book, name: 'livelib_rating')
    BookRating.create!(book_id: book.id, rating: Rating::INSTANCES['livelib'], average: 7, votes_count: 15)
  end
  given(:with_writing_year_book) { create(:book, writing_year: 12345, name: 'writing_year') }
  given(:with_pages_count) { create(:book, pages_count: 12345, name: 'pages_count') }
  given(:with_comments_count) { create(:book, comments_count: 12345, name: 'comments_count') }
  given(:all_type_books) do
    with_genre_book
    first_added_book
    last_added_book
    with_litres_rating_book
    with_livelib_rating_book
    with_writing_year_book
    with_pages_count
    with_comments_count
  end
  # Необходимо, т.к. тестовая среда уничтожает данные Rating и замороженный хэш начинает указывать на пустое место
  given(:reinitialize_rating_instances_constant) do
    Rating::INSTANCES = {
      'litres' => (Rating.find_by(name: 'litres') || Rating.create!(name: 'litres')),
      'livelib' => (Rating.find_by(name: 'livelib') || Rating.create!(name: 'livelib'))
    }
  end
  given(:user) { create(:user) }

  describe 'Authenticated user tries to search for a books', js: true do
    before { sign_in(user) }
    
    scenario 'and after re-visit search page use old search parameters for a new search' do
      reinitialize_rating_instances_constant
      all_type_books
      visit(searches_index_path)
      find(:xpath, "//div[@data-search-filter='search-filter-writing-year']").click
      fill_in 'writing_year', with: 1234
      click_on 'Найти'

      visit(searches_index_path)
      find(".old-search-area input[type='submit']").click
      find(:xpath, "//div[@data-search-filter-item='search-filter-start-date-added']").click
      click_on 'Найти'
      
      wait_for_ajax
      within '.search-result-list' do
        expect(page).not_to have_content 'with_genre'
        expect(page).not_to have_content 'first_added'
        expect(page).not_to have_content 'last_added'
        expect(page).not_to have_content 'litres_rating'
        expect(page).not_to have_content 'livelib_rating'
        expect(page).to have_content 'writing_year'
        expect(page).not_to have_content 'pages_count'
        expect(page).not_to have_content 'comments_count'
      end
    end
  end
end
