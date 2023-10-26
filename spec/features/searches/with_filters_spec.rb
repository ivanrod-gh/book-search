require 'rails_helper'

feature 'User can search for books with filters', %q{
  In order to find a needed books by specific criteria
  As an any user
  I'd like to be able to search for the book with specific search filters
} do
  given(:md_genre) { create(:genre, :modern_detectives) }
  given(:with_genre_book) do
    book = create(:book, name: 'with_genre')
    BookGenre.create(book: book, genre: md_genre)
  end
  given(:first_added_book) { create(:book, :date_added_1998, name: 'first_added') }
  given(:last_added_book) { create(:book, :date_added_2025, name: 'last_added') }
  given(:with_litres_rating_book) do
    book = create(:book, name: 'litres_rating')
    BookRating.create(book_id: book.id, rating: Rating::INSTANCES['litres'], average: 8, votes_count: 10)
  end
  given(:with_livelib_rating_book) do
    book = create(:book, name: 'livelib_rating')
    BookRating.create(book_id: book.id, rating: Rating::INSTANCES['livelib'], average: 7, votes_count: 15)
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
      'litres' => (Rating.find_by(name: 'litres') || Rating.create(name: 'litres')),
      'livelib' => (Rating.find_by(name: 'livelib') || Rating.create(name: 'livelib'))
    }
  end
  given(:forty_nine_books) { create_list(:book, 49) }
  given(:user) { create(:user) }

  describe 'Any user tries to search for a books', js: true do
    scenario 'with no filters then no books exist' do
      visit(searches_index_path)
      click_on 'Найти'

      wait_for_ajax
      within '.search-result-list' do
        expect(page).to have_content 'По вашему запросу ничего не найдено'
      end
    end

    scenario 'with no filters then all books exist' do
      reinitialize_rating_instances_constant
      all_type_books
      visit(searches_index_path)
      click_on 'Найти'

      wait_for_ajax
      within '.search-result-list' do
        expect(page).to have_content 'with_genre'
        expect(page).to have_content 'first_added'
        expect(page).to have_content 'last_added'
        expect(page).to have_content 'litres_rating'
        expect(page).to have_content 'livelib_rating'
        expect(page).to have_content 'writing_year'
        expect(page).to have_content 'pages_count'
        expect(page).to have_content 'comments_count'
      end
    end

    describe 'then many diferent type books exist' do
      before do
        reinitialize_rating_instances_constant
        all_type_books
        visit(searches_index_path)
      end

      scenario 'with genre filter' do
        find(:xpath, "//div[@data-search-filter='search-filter-genre-int-id']").click
        find('select#genre_int_id').find(:option, md_genre.name).select_option
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).to have_content 'with_genre'
          expect(page).not_to have_content 'first_added'
          expect(page).not_to have_content 'last_added'
          expect(page).not_to have_content 'litres_rating'
          expect(page).not_to have_content 'livelib_rating'
          expect(page).not_to have_content 'writing_year'
          expect(page).not_to have_content 'pages_count'
          expect(page).not_to have_content 'comments_count'
        end
      end

      scenario 'with start date added filter' do
        find(:xpath, "//div[@data-search-filter-item='search-filter-start-date-added']").click
        find('select#_start_date_added_1i').find(:option, '2025').select_option
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).not_to have_content 'with_genre'
          expect(page).not_to have_content 'first_added'
          expect(page).to have_content 'last_added'
          expect(page).not_to have_content 'litres_rating'
          expect(page).not_to have_content 'livelib_rating'
          expect(page).not_to have_content 'writing_year'
          expect(page).not_to have_content 'pages_count'
          expect(page).not_to have_content 'comments_count'
        end
      end

      scenario 'with end date added filter' do
        find(:xpath, "//div[@data-search-filter-item='search-filter-end-date-added']").click
        find('select#_end_date_added_1i').find(:option, '1998').select_option
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).not_to have_content 'with_genre'
          expect(page).to have_content 'first_added'
          expect(page).not_to have_content 'last_added'
          expect(page).not_to have_content 'litres_rating'
          expect(page).not_to have_content 'livelib_rating'
          expect(page).not_to have_content 'writing_year'
          expect(page).not_to have_content 'pages_count'
          expect(page).not_to have_content 'comments_count'
        end
      end

      scenario 'with minimum litres average rating filter' do
        find(:xpath, "//div[@data-search-filter-item='search-filter-rating-litres-average']").click
        fill_in 'rating_litres_average', with: 5
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).not_to have_content 'with_genre'
          expect(page).not_to have_content 'first_added'
          expect(page).not_to have_content 'last_added'
          expect(page).to have_content 'litres_rating'
          expect(page).not_to have_content 'livelib_rating'
          expect(page).not_to have_content 'writing_year'
          expect(page).not_to have_content 'pages_count'
          expect(page).not_to have_content 'comments_count'
        end
      end

      scenario 'with minimum litres votes count filter' do
        find(:xpath, "//div[@data-search-filter-item='search-filter-rating-litres-votes-count']").click
        fill_in 'rating_litres_votes_count', with: 5
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).not_to have_content 'with_genre'
          expect(page).not_to have_content 'first_added'
          expect(page).not_to have_content 'last_added'
          expect(page).to have_content 'litres_rating'
          expect(page).not_to have_content 'livelib_rating'
          expect(page).not_to have_content 'writing_year'
          expect(page).not_to have_content 'pages_count'
          expect(page).not_to have_content 'comments_count'
        end
      end

      scenario 'with minimum livelib average rating filter' do
        find(:xpath, "//div[@data-search-filter-item='search-filter-rating-livelib-average']").click
        fill_in 'rating_livelib_average', with: 5
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).not_to have_content 'with_genre'
          expect(page).not_to have_content 'first_added'
          expect(page).not_to have_content 'last_added'
          expect(page).not_to have_content 'litres_rating'
          expect(page).to have_content 'livelib_rating'
          expect(page).not_to have_content 'writing_year'
          expect(page).not_to have_content 'pages_count'
          expect(page).not_to have_content 'comments_count'
        end
      end

      scenario 'with minimum livelib votes count filter' do
        find(:xpath, "//div[@data-search-filter-item='search-filter-rating-livelib-votes-count']").click
        fill_in 'rating_livelib_votes_count', with: 5
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).not_to have_content 'with_genre'
          expect(page).not_to have_content 'first_added'
          expect(page).not_to have_content 'last_added'
          expect(page).not_to have_content 'litres_rating'
          expect(page).to have_content 'livelib_rating'
          expect(page).not_to have_content 'writing_year'
          expect(page).not_to have_content 'pages_count'
          expect(page).not_to have_content 'comments_count'
        end
      end

      scenario 'with minimum writing year filter' do
        find(:xpath, "//div[@data-search-filter='search-filter-writing-year']").click
        fill_in 'writing_year', with: 5
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

      scenario 'with minimum pages count filter' do
        find(:xpath, "//div[@data-search-filter='search-filter-pages-count']").click
        fill_in 'pages_count', with: 5
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).not_to have_content 'with_genre'
          expect(page).not_to have_content 'first_added'
          expect(page).not_to have_content 'last_added'
          expect(page).not_to have_content 'litres_rating'
          expect(page).not_to have_content 'livelib_rating'
          expect(page).not_to have_content 'writing_year'
          expect(page).to have_content 'pages_count'
          expect(page).not_to have_content 'comments_count'
        end
      end

      scenario 'with minimum comments count filter' do
        find(:xpath, "//div[@data-search-filter='search-filter-comments-count']").click
        fill_in 'comments_count', with: 5
        click_on 'Найти'

        wait_for_ajax
        within '.search-result-list' do
          expect(page).not_to have_content 'with_genre'
          expect(page).not_to have_content 'first_added'
          expect(page).not_to have_content 'last_added'
          expect(page).not_to have_content 'litres_rating'
          expect(page).not_to have_content 'livelib_rating'
          expect(page).not_to have_content 'writing_year'
          expect(page).not_to have_content 'pages_count'
          expect(page).to have_content 'comments_count'
        end
      end
    end

    describe 'then many books exist' do
      scenario 'paginate to second page' do
        reinitialize_rating_instances_constant
        forty_nine_books
        first_added_book
        visit(searches_index_path)
        click_on 'Найти'
        within '.paginate-links-list' do
          click_on '2'
        end

        wait_for_ajax
        within '.search-result-list' do
          expect(page).to have_content 'first_added'
        end
      end
    end
  end

  describe 'Authenticated user tries to search for a books', js: true do
    before { sign_in(user) }

    scenario 'and get his search request saved if books exist' do
      reinitialize_rating_instances_constant
      all_type_books
      visit(searches_index_path)
      click_on 'Найти'

      wait_for_ajax
      within '.old-search-area' do
        expect(page).to have_content user.searches.first.updated_at.to_s
      end
    end
  end
end
